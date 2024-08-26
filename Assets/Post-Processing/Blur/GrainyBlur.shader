Shader "Post-Processing/GrainyBlur"
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
			float _Radius;
			int _Iteration;

			float rand(float2 n)
			{
				return sin(dot(n, half2(1233.224, 1743.335)));
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
				half2 randomOffset = float2(0.0,0.0);
				float random = rand(i.uv);

				for(int it = 0; it < _Iteration; it++){
					random = frac(43758.5453 * random + 0.61432);
					randomOffset.x = (random - 0.5) * 2.0;
					random = frac(43758.5453 * random + 0.61432);
					randomOffset.y = (random - 0.5) * 2.0;

					col += tex2D(_MainTex,i.uv + randomOffset * _Radius);
				}
				return col / _Iteration;
			}

			ENDCG
		}  
	}
	Fallback Off
}
