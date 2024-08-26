Shader "Post-Processing/TiltShiftBlur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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
			half _RotateDistance,_Radius,_Pow,_Offset,_Area;
			int _SampleCount;


			fixed TiltShiftMask(fixed2 uv)
			{
				float centerY = uv.y * 2.0 - 1.0 + _Offset;
				return saturate(pow(abs(centerY * _Area),_Pow));
			}

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
				fixed singleWeight = 1;
				float totalWeight = 0;
				float2 angle = float2(0,_Radius);
				float rotateCos = cos(_RotateDistance);
				float rotateSin = sin(_RotateDistance);

				float2x2 rotateMatrix = float2x2(float2(rotateCos,rotateSin),
												float2(-rotateSin,rotateCos));
				for(int it = 0; it < _SampleCount; it++){
					singleWeight += 1/singleWeight;
					angle = mul(rotateMatrix,angle);
					fixed4 color = tex2D(_MainTex,i.uv + angle * _MainTex_TexelSize.xy * (singleWeight - 1));

					col += color;
					totalWeight += 1;
				}
				fixed4 blurColor = col / totalWeight;

				fixed4 texColor = tex2D(_MainTex,i.uv);
				fixed blurStrength = TiltShiftMask(i.uv);

				return blurColor * blurStrength + (1-blurStrength) * texColor;
			}

			ENDCG
		}  
	}
	Fallback Off
}
