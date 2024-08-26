Shader "NPR Paint Filter/Abstract Painting" {
	Properties {
		_MainTex ("Main", 2D) = "white" {}
	}
	SubShader {
		Cull Off ZWrite Off ZTest Always
		Pass {
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			#include "UnityCG.cginc"
			sampler2D _MainTex;
			float _EdgeWeight, _Brightness;

			float4 frag (v2f_img input) : SV_Target
			{
				float2 uv = input.uv;
				float offset = 1.0 / (_EdgeWeight * 100.0);
				float3 o = float3(-offset, 0.0, offset);
				float4 gx = 0.0;
				float4 gy = 0.0;
				float4 t;

				gx += tex2D(_MainTex, uv + o.xz);
				gy += gx;
				gx += _Brightness * tex2D(_MainTex, uv + o.xy);
				t = tex2D(_MainTex, uv + o.xx);

				gx += t;
				gy -= t;
				gy += _Brightness * tex2D(_MainTex, uv + o.yz);
				gy -= _Brightness * tex2D(_MainTex, uv + o.yx);
				t = tex2D(_MainTex, uv + o.zz);

				gx -= t;
				gy += t;
				gx -= _Brightness * tex2D(_MainTex, uv + o.zy);
				t = tex2D(_MainTex, uv + o.zx);
				gx -= t;
				gy -= t;
				return sqrt(gx * gx + gy * gy);
			}
			ENDCG
		}
	}
	FallBack Off
}