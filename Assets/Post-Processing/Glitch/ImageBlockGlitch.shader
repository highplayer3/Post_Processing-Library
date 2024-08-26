Shader "Post-Processing/Glitch/ImageBlockGlitch"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Cull Off ZWrite Off ZTest Always
        CGINCLUDE
        #include "UnityCG.cginc"

        sampler2D _MainTex;
        half4 _MainTex_TexelSize;
        int _Row1,_Row2,_Col1,_Col2;
        fixed _Speed,_Intensity1,_Intensity2,_Pow1,_Pow2;

        struct v2f
        {
            float4 pos : SV_POSITION;
            half2 uv : TEXCOORD0;
        };

        inline float randomNoise(float2 seed)
	    {
	    	return frac(sin(dot(seed * floor(_Time.y * _Speed), float2(17.13, 3.71))) * 43758.5453123);
	    }

	    inline float simpleNoise(float seed)
        {
            return frac(sin(seed * 2114.442 + _Time.y * _Speed / 100+4546.112) * 6631.423);
        }

        v2f vert(appdata_img v)
        {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv = v.texcoord;
            return o;
        }

        half4 frag(v2f i) : SV_Target
        {
            //float2 block = randomNoise(floor(i.uv * _BlockSize));
            //float displaceNoise = pow(block.x,8.0) * pow(block.x,3.0);

            //half colorR = tex2D(_MainTex,i.uv).r;
            //half colorG = tex2D(_MainTex,i.uv + float2(displaceNoise * 0.05 * randomNoise(7.0),0.0)).g;
            //half ColorB = tex2D(_MainTex,i.uv - float2(displaceNoise * 0.05 * randomNoise(13.0), 0.0)).b;

            //return half4(colorR,colorG,ColorB,1);
            float noise1 = simpleNoise(floor(i.uv.x * _Col1) + floor(i.uv.y * _Row1) * _Col1);
            noise1 = pow(noise1,_Pow1);
            float noise2 = simpleNoise(floor(i.uv.x * _Col2) + floor(i.uv.y * _Row2) * _Col2);
            noise2 = pow(noise2,_Pow2);

            float noise = noise1 * noise2;

            fixed colorR = tex2D(_MainTex,i.uv).r;
            fixed colorG = tex2D(_MainTex,i.uv + noise * _Intensity1 * _MainTex_TexelSize.xy).g;
            fixed colorB = tex2D(_MainTex,i.uv - noise * _Intensity2 * _MainTex_TexelSize.xy).b;

            return fixed4(colorR,colorG,colorB,1);

        }

        ENDCG

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            ENDCG
        }
    }
    FallBack Off
}
