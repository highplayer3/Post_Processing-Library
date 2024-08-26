Shader "NPR Paint Filter/BluePrint" {
	Properties {
		_MainTex ("Main", 2D) = "white" {}
	}
	CGINCLUDE
		#include "UnityCG.cginc"
		sampler2D _MainTex, _BgTex;
		float4 _PencilColor, _BgColor;
		float _TimeCustom, _Size, _PencilIntensity, _AnimSpeed, _Vignette, _FadePaper2Bg, _Fade2Orig, _AnimIntensity;

		float4 frag (v2f_img input) : COLOR
       	{
       		float2 uvst = input.uv;//UnityStereoScreenSpaceUVAdjust(i.tex, _MainTex_ST);
			float4 f = tex2D(_MainTex, uvst);
			float3 paper = tex2D(_BgTex, uvst).rgb;
			
			float tt = _TimeCustom * _AnimSpeed;
			float s = floor(sin(tt * 10) * 0.02) * _AnimIntensity;
			float c = floor(cos(tt * 10) * 0.02) * _AnimIntensity;
			float2 dist = float2(c + paper.b * 0.02, s + paper.b * 0.02);
			float3 paper2 = tex2D(_BgTex, uvst + dist).rgb;
			
			float4 tex1[4];
			float4 tex2[4];
			tex2[0] = tex2D(_MainTex, uvst + float2(_Size, 0) + dist / 128);
			tex2[1] = tex2D(_MainTex, uvst + float2(-_Size, 0) + dist / 128);
			tex2[2] = tex2D(_MainTex, uvst + float2(0, _Size) + dist / 128);
			tex2[3] = tex2D(_MainTex, uvst + float2(0, -_Size) + dist / 128);
			
			float ce = 1.0;
			for(int i = 0; i < 4; i++)
			{
				tex1[i] = saturate(1.0 - distance(tex2[i].r, f.r));
				tex1[i] *= saturate(1.0 - distance(tex2[i].g, f.g));
				tex1[i] *= saturate(1.0 - distance(tex2[i].b, f.b));
				tex1[i] = pow(tex1[i], _PencilIntensity);
				ce *= dot(tex1[i], 1.0);
			}
			
			ce = saturate(ce);
			float3 ax = 1.0 - ce; 
			ax *= paper2.b;
			ax = lerp(float3(0.0, 0.0, 0.0), ax * 1.5, 1.0);
			ax = lerp(ax, float3(0, 0, 0), lerp(1.0 - paper.g, 0.0, _Vignette));
			paper = lerp(float3(0.1 + paper.r * 0.175, 0.1 + paper.r * 0.402, 0.1 + paper.r * 0.687), _BgColor.rgb, _FadePaper2Bg); 
			paper = lerp(paper, _PencilColor.rgb, ax);
			paper = lerp(f, paper, _Fade2Orig);
			return float4(paper, 1.0);
       	}
	ENDCG
	SubShader {
		ZTest Off Cull Off ZWrite Off Blend Off
	  	Fog { Mode off }  
		Pass {
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			ENDCG
		}
	}
	FallBack Off
}