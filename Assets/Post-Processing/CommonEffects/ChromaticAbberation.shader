Shader "Post-Processing/ChromaticAbberation"
{
    Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_ChromaticFactor ("Chromatic Factor", Float) = 0
		_ChromaticRegionFactor ("ChromaticRegionFactor", Float) = 1
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
			float _ChromaticFactor,_ChromaticRegionFactor;
			  
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
				fixed4 col;

				float2 expandTexcoord = i.uv * 2 - 1;//将uv值从0,1->-1,1
				float radicalGradient = dot(expandTexcoord,expandTexcoord);//得到屏幕空间的圆形遮罩
				radicalGradient = saturate(pow(radicalGradient,_ChromaticRegionFactor));
				//同理可以得到水平遮罩:dot(expandTexcoord.y,expandTexcoord.y);垂直遮罩:dot(x,x);
				//为什么要三次方仅仅为了避免平方根的运算
				radicalGradient = radicalGradient * radicalGradient * radicalGradient;

				half colR = tex2D(_MainTex,i.uv + float2(_ChromaticFactor,_ChromaticFactor) * 0.1 * radicalGradient).r;
				half colG = tex2D(_MainTex,i.uv).g;
				half colB = tex2D(_MainTex,i.uv - float2(_ChromaticFactor,_ChromaticFactor) * 0.1 * radicalGradient).b;
				col.rgb = fixed3(colR,colG,colB);

				return col;
			}  
			  
			ENDCG
		}  
	}
	
	Fallback Off
}
