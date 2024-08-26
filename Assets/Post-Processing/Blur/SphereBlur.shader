Shader "Post-Processing/SphereBlur"
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
			half _Radius,_Pow;

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
				for(int y = -_Radius; y <= _Radius; y++){
					for(int x = -_Radius; x <= _Radius;x++){
						float2 uv = i.uv + _MainTex_TexelSize.xy * fixed2(x,y);
						float dis = distance(float2(x,y), 0);
						float inRange = step(dis,_Radius);

						float weight = pow((float)1/(1+dis),_Pow);
						col += tex2D(_MainTex,uv) * inRange * weight;
						totalWeight += inRange * weight;
					}
				}
				return col / totalWeight;
			}

			ENDCG
		}  
	}
	Fallback Off
}
