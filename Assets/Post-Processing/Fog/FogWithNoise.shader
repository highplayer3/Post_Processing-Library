Shader "Post-Processing/Fog/FogWithNoise"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" 
        _FogDensity ("Fog Density", Float) = 1.0
        //_FogColor ("Fog Color", Color) = (1, 1, 1, 1)
        _FogStart ("Fog Start", Float) = 0.0
        _FogEnd ("Fog End", Float) = 1.0
        _NoiseTex ("Noise Texture", 2D) = "white" {}
        _FogXSpeed ("Fog X Speed", Float) = 0.1
        _FogYSpeed ("Fog Y Speed", Float) = 0.1
        _NoiseAmount ("Noise Amount", Float) = 1
    }
    SubShader
    {
        ZTest Always Cull Off ZWrite Off
        CGINCLUDE
        #include"UnityCG.cginc"

        float4x4 _FrustumCornersRay;
        sampler2D _MainTex;
        half4 _MainTex_TexelSize;
        sampler2D _CameraDepthTexture;
        half _FogDensity,_NoiseAmount;
        float _FogStart,_FogEnd,_FogXSpeed,_FogYSpeed;
        fixed4 _FogColor;
        sampler2D _NoiseTex;
        

        struct v2f
        {
            float4 pos : SV_POSITION;
            half2 uv : TEXCOORD0;
            half2 uv_depth : TEXCOORD1;
            float4 interpolatedRay : TEXCOORD2;
        };

        v2f vert(appdata_img v)
        {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);

            o.uv = v.texcoord;
            o.uv_depth = v.texcoord;

            #if UNITY_UV_STARTS_AT_TOP
                if(_MainTex_TexelSize.y < 0){
                    o.uv_depth.y = 1 - o.uv_depth.y;
                }
            #endif

            int index = 0;
            if(v.texcoord.x < 0.5 && v.texcoord.y < 0.5){
                index = 0;
            }else if(v.texcoord.x > 0.5 && v.texcoord.y < 0.5){
                index = 1;
            }else if(v.texcoord.x > 0.5 && v.texcoord.y > 0.5){
                index = 2;
            }else{
                index = 3;
            }

            #if UNITY_UV_STARTS_AT_TOP
                if(_MainTex_TexelSize.y < 0){
                    index = 3 - index;
                }
            #endif

            o.interpolatedRay = _FrustumCornersRay[index];

            return o;
        }

        float3 GetWorldPos(v2f i)
        {
            float linearDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,i.uv_depth));
            return _WorldSpaceCameraPos + linearDepth * i.interpolatedRay.xyz;
        }

        float Sample_NoiseTex(v2f i)
        {
            float2 speed = float2(_FogXSpeed,_FogYSpeed) * _Time.y;
            float noise = (tex2D(_NoiseTex,i.uv + speed).r - 0.5) * _NoiseAmount;
            return noise;
        }
        //Pass0-线性高度雾
        fixed4 frag_LinearHeight(v2f i) : SV_Target
        {
            float3 worldPos = GetWorldPos(i);
            float noiseVal = Sample_NoiseTex(i);

            float fogDensity = ((_FogEnd - worldPos.y) / (_FogEnd - _FogStart)) * (1 + noiseVal);
            fogDensity = saturate(fogDensity * _FogDensity);

            fixed4 col = tex2D(_MainTex,i.uv);
            return fixed4(lerp(col.rgb,_FogColor.rgb,fogDensity),1.0);
        }

        //Pass1-线性距离雾
        fixed4 frag_LinearDistance(v2f i) : SV_Target
        {
            float3 worldPos = GetWorldPos(i);
            float dis = distance(_WorldSpaceCameraPos,worldPos);
            //float dis = worldPos.z;
            float noiseVal = Sample_NoiseTex(i);

            float fogDensity = (dis - _FogStart) / (_FogEnd - _FogStart) * (1 + noiseVal);
            fogDensity = saturate(fogDensity * _FogDensity);

            fixed4 col = tex2D(_MainTex,i.uv);
            return fixed4(lerp(col.rgb,_FogColor.rgb,fogDensity),1.0);
        }

        //Pass2-指数高度雾
        fixed4 frag_ExponentialHeight(v2f i) : SV_Target
        {
            float3 worldPos = GetWorldPos(i);
            float noiseVal = Sample_NoiseTex(i);

            float fogDensity = saturate(exp(-(_FogDensity * (worldPos.y - _FogStart))) * (1 + noiseVal));
            //fogDensity = saturate(fogDensity * _FogDensity);

            fixed4 col = tex2D(_MainTex,i.uv);
            return fixed4(lerp(col.rgb,_FogColor.rgb,fogDensity),1.0);
        }

        //Pass3-指数距离雾
        fixed4 frag_ExponentialDistance(v2f i) : SV_Target
        {
            float3 worldPos = GetWorldPos(i);
            float noiseVal = Sample_NoiseTex(i);

            //float dis = (distance(_WorldSpaceCameraPos,worldPos) - _FogStart) / _ProjectionParams.z;
            //float fogDensity = saturate(dis * pow(2,_FogDensity) * (1 + noiseVal));

            float dis = distance(_WorldSpaceCameraPos,worldPos); /// _ProjectionParams.z;
            float fogDensity = exp(-((_FogEnd - _FogStart) * (_FogStart - dis) * noiseVal * -0.001));
            fogDensity = saturate(fogDensity * _FogDensity);

            fixed4 col = tex2D(_MainTex,i.uv);
            return fixed4(lerp(col.rgb,_FogColor.rgb,fogDensity),1.0);
        }
        //fixed4 frag(v2f i) : SV_Target
        //{
        //    float linearDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,i.uv_depth));
        //    float3 worldPos = _WorldSpaceCameraPos + linearDepth * i.interpolatedRay.xyz;

        //    float2 speed = float2(_FogXSpeed,_FogYSpeed) * _Time.y;
        //    float noise = (tex2D(_NoiseTex,(i.uv + speed)).r - 0.5) * _NoiseAmount;



        //    float fogDensity = ((_FogEnd - worldPos.y) / (_FogEnd - _FogStart)) * (1 + noise);
        //    fogDensity = saturate(fogDensity * _FogDensity);

        //    fixed4 finalColor = tex2D(_MainTex,i.uv);
        //    finalColor.rgb = lerp(finalColor.rgb,_FogColor.rgb,fogDensity);

        //    return finalColor;
        //}

        ENDCG
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag_LinearHeight
            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag_LinearDistance
            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag_ExponentialHeight
            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag_ExponentialDistance
            ENDCG
        }
    }
    FallBack Off
}
