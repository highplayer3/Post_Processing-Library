Shader "Post-Processing/Artistic/ScreenWaterEffect"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ScreenWaterDropTex ("Water Drop Texture", 2D) = "white" {}
        _CurTime ("Time", Range(0.0,1.0)) = 1.0
        _SizeX ("SizeX", Range(0.0,1.0)) = 1.0
        _SizeY ("SizeY", Range(0.0,1.0)) = 1.0
        _DropSpeed ("Drop Speed", Range(0.0,10.0)) = 1.0
        _Distortion ("Distortion", Range(0.0,1.0)) = 0.87
    }
    SubShader
    {
        Pass
        {
            ZTest Always Cull Off ZWrite Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct a2v
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                half2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            uniform sampler2D _MainTex;
            uniform sampler2D _ScreenWaterDropTex;
            uniform float2 _MainTex_TexelSize;
            uniform float _CurTime,_DropSpeed,_SizeX,_SizeY,_Distortion;

            v2f vert (a2v v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //矫正不同平台上的方向问题
                #if UNITY_UV_STARTS_AT_TOP
                if(_MainTex_TexelSize.y < 0){
                    _DropSpeed = 1 - _DropSpeed;
                }
                #endif

                float3 rainTex1 = tex2D(_ScreenWaterDropTex,float2(i.uv.x * 1.15 * _SizeX,(i.uv.y * _SizeY * 1.1) + _CurTime * _DropSpeed * 0.15)).rgb / _Distortion;
                float3 rainTex2 = tex2D(_ScreenWaterDropTex,float2(i.uv.x * 1.25 * _SizeX - 0.1,(i.uv.y * _SizeY * 1.2) + _CurTime * _DropSpeed * 0.2)).rgb / _Distortion;
                float3 rainTex3 = tex2D(_ScreenWaterDropTex, float2(i.uv.x * _SizeX *0.9, (i.uv.y * _SizeY * 1.25) + _CurTime * _DropSpeed* 0.032)).rgb / _Distortion;

                float2 finalRainTex = i.uv.xy - (rainTex1.xy - rainTex2.xy - rainTex3.xy) / 3;

                float3 finalColor = tex2D(_MainTex,float2(finalRainTex.x,finalRainTex.y)).rgb;

                return fixed4(finalColor,1.0);
            }
            ENDCG
        }
    }
}
