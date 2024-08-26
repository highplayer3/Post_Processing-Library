Shader "Post-Processing/BrightnessSaturationAndContrast"
{
    Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}//必须要有_MainTex属性来接收Graphics.Blit函数的第一个参数
		_Brightness ("Brightness", Float) = 1
		_Saturation("Saturation", Float) = 1
		_Contrast("Contrast", Float) = 1
		//注意，上面三个用于调整后处理效果的参数可以不用声明，因为声明只是为了显示在材质面板上
		//而我们的材质是临时创建的，也不需要在材质上调整参数，而是从脚本中传递的。
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
			half _Brightness;
			half _Saturation;
			half _Contrast;
			  
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
				fixed4 renderTex = tex2D(_MainTex, i.uv);  
				  
				//屏幕亮度计算
				fixed3 finalColor = renderTex.rgb * _Brightness;
				
				// 屏幕的饱和度计算
				fixed luminance = 0.2125 * renderTex.r + 0.7154 * renderTex.g + 0.0721 * renderTex.b;
				fixed3 luminanceColor = fixed3(luminance, luminance, luminance);
				finalColor = lerp(luminanceColor, finalColor, _Saturation);
				
				// Apply contrast
				fixed3 avgColor = fixed3(0.5, 0.5, 0.5);
				finalColor = lerp(avgColor, finalColor, _Contrast);
				
				return fixed4(finalColor, renderTex.a);  
			}  
			  
			ENDCG
		}  
	}
	
	Fallback Off
}
