Shader "NPR Paint Filter/Halftone" {
	Properties {
		[HideInInspector]_MainTex ("Main", 2D) = "white" {}
		[NoScaleOffset]_MaskTex ("Mask", 2D) = "white" {}
		_BlockSize ("Block Size", Range(1, 16)) = 8
		_Scale ("Scale", Float) = 256
		_Power ("Power", Range(0.01, 16)) = 2
		_Step1 ("Step1", Float) = 0.1
		_Step2 ("Step2", Float) = 0.3
		_Step3 ("Step3", Float) = 0.5
		_Fade  ("Fade", Range(0, 1)) = 0
	}
	SubShader {
		Cull Off ZWrite Off ZTest Always
		Pass {
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			#include "UnityCG.cginc"
			sampler2D _MainTex, _MaskTex;
			float4 _MainTex_TexelSize;
			float _Scale, _BlockSize, _Power, _Step1, _Step2, _Step3, _Fade;
			float _BayerMatrix[256];

			float BayerDither (float2 scrpos)
			{
				scrpos = frac(floor(scrpos) / 16);
				return _BayerMatrix[scrpos.x * 256 + scrpos.y * 16];
			}
			float4 frag (v2f_img input) : SV_Target
			{
				float2 block = _MainTex_TexelSize.xy * _BlockSize;
				float2 uv = trunc(input.uv / block) * block;
				
				fixed4 tc = tex2D(_MainTex, uv);
				
				float g = Luminance(tc.rgb);
				g = pow(g, _Power);

				float r = step(_Step1, g) * _Step2;
				r = max(r, step(_Step2, g) * _Step3);
				r = max(r, step(_Step3, g) * 0.8);
				
				float dither = BayerDither(input.uv * _Scale);

				fixed4 mask = tex2D(_MaskTex, input.uv * _Scale);
				mask = saturate(mask * 12);
				mask = lerp(1.0 - dither, mask, mask >= 0);

				r = 1.0 - (1.0 - r) * dither * mask;
				
				float3 c = lerp(r, r * tc.rgb, _Fade);
				return float4(c, 1.0);
			}
			ENDCG
		}
	}
	FallBack Off
}