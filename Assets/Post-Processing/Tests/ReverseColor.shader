Shader "Post-Processing/ReverseColor"
{
    Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}//必须要有_MainTex属性来接收Graphics.Blit函数的第一个参数
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

				col.rgb = 1 - col.rgb;
				return col;
			}  
			  
			ENDCG
		}  
	}
	
	Fallback Off
}
