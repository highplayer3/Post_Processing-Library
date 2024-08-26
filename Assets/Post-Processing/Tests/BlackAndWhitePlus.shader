Shader "Post-Processing/BlackAndWhitePlus"
{
    Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_Threshold ("Threshold", Float) = 0.5
		_ShadowColor ("Shadow Color", Color) = (1,1,1,1)
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
			  
			sampler2D _MainTex; 
			float _Threshold;
			fixed4 _ShadowColor;
			  
			struct v2f {
				float4 pos : SV_POSITION;
				half2 uv: TEXCOORD0;
			};
			  
			v2f vert(appdata_img v) {
				v2f o;
				
				o.pos = UnityObjectToClipPos(v.vertex);
				
				o.uv = v.texcoord;
						 
				return o;
			}
		
			fixed4 frag(v2f i) : SV_Target {
				fixed4 col = tex2D(_MainTex,i.uv);
				fixed4 texCol = col;
				//这种黑白图是明度保持不变的
				float luminance = (col.r * 0.29 + col.g * 0.59 + col.b * 0.12);
				
				col.rgb = step(_Threshold,luminance);
				col.rgb = lerp(_ShadowColor.rgb,texCol.rgb,col.r);
				return fixed4(col.rgb,1);
			}  
			  
			ENDCG
		}  
	}
	
	Fallback Off
}
