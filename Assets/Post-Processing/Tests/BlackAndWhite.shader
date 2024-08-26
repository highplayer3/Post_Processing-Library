Shader "Post-Processing/BlackAndWhite"
{
    Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}//����Ҫ��_MainTex����������Graphics.Blit�����ĵ�һ������
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
				//���ֺڰ�ͼ�����ȱ��ֲ����
				float luminance = (col.r * 0.29 + col.g * 0.59 + col.b * 0.12);
				return luminance;
			}  
			  
			ENDCG
		}  
	}
	
	Fallback Off
}
