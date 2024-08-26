Shader "Post-Processing/KawaseBlur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BlurSize ("Blur Size", Float) = 1
    }

    SubShader 
	{
		ZTest Always Cull Off ZWrite Off
		Pass 
		{  
			CGPROGRAM  
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct v2f 
			{
				float4 pos : SV_POSITION;
				half2 uv : TEXCOORD0;//5x5的高斯核
			};

			sampler2D _MainTex;  
			half4 _MainTex_TexelSize;//纹素大小(512x512---->纹素大小:1/512)
			float _BlurSize;

			v2f vert(appdata_img v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 col = 0;
				col += tex2D(_MainTex,i.uv + half2(0.5,0.5) * _MainTex_TexelSize.xy * _BlurSize);
				col += tex2D(_MainTex,i.uv + half2(-0.5,-0.5) * _MainTex_TexelSize.xy * _BlurSize);
				col += tex2D(_MainTex,i.uv + half2(0.5,-0.5) * _MainTex_TexelSize.xy * _BlurSize);
				col += tex2D(_MainTex,i.uv + half2(-0.5,0.5) * _MainTex_TexelSize.xy * _BlurSize);

				col *= 0.25;
				return col;
			}

			ENDCG
		}  
	}
	Fallback Off
}
