Shader "Post-Processing/RadialBlur"
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
				half2 uv : TEXCOORD0;
			};

			sampler2D _MainTex;  
			half4 _MainTex_TexelSize;
			float _BlurRadius;
			int _Iteration;
			half2 _RadialCenter;

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
				float totalWeight = 0;
				float2 direction = (i.uv - _RadialCenter);

				for(int it = 0; it < _Iteration; it++){
					float2 newUV = i.uv + direction * it * _MainTex_TexelSize.xy * _BlurRadius * 5;
					float singleWeight = 1 - dot(direction.x,direction.y);
					col += tex2D(_MainTex,newUV) * singleWeight;
					totalWeight += singleWeight;
				}
				return col / totalWeight;
			}

			ENDCG
		}  
	}
	Fallback Off
}
