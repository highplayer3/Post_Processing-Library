Shader "Post-Processing/DirectionalBlur"
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
			fixed2 _Direction;
			int _Iteration;

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
				for(int it = 0; it < _Iteration; it++){
					float weight = (float)1 / (it+1);
					totalWeight += weight;
					col += tex2D(_MainTex,i.uv + it * _Direction * _MainTex_TexelSize.xy) * weight;
				}
				return col / totalWeight;
			}

			ENDCG
		}  
	}
	Fallback Off
}
