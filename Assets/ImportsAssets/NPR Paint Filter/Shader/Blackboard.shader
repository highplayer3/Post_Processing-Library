// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "NPR Paint Filter/Blackboard" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_EdgeColor ("Edge Color", Color) = (1, 1, 1, 1)
		_EdgeThreshold ("Edge Threshold", Range(0, 1)) = 0.07
		_SampleDist ("Sample Distance", Range(0, 0.1)) = 0.007
		_Hardness ("Hardness", Range(0, 1)) = 0.24
	}
	CGINCLUDE
		#include "UnityCG.cginc"
		sampler2D _MainTex;
		float4 _EdgeColor;
		float _EdgeThreshold, _SampleDist, _Hardness;
		struct v2f
		{
			float4 pos : POSITION;
			float2 tex : TEXCOORD0;
		};
		v2f vert (appdata_base v)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.tex = v.texcoord.xy;
			return o;
		}
		float4 fragEdge (v2f i) : COLOR
       	{
       		float2 os = float2(1 / _ScreenParams.x, 1 / _ScreenParams.y);

			float s00 = tex2D(_MainTex, i.tex + float2(-os.x, -os.y)).r;
			float s01 = tex2D(_MainTex, i.tex + float2( 0,    -os.y)).r;
			float s02 = tex2D(_MainTex, i.tex + float2( os.x, -os.y)).r;
			float s10 = tex2D(_MainTex, i.tex + float2(-os.x,  0    )).r;
			float s12 = tex2D(_MainTex, i.tex + float2( os.x,  0    )).r;
			float s20 = tex2D(_MainTex, i.tex + float2(-os.x,  os.y)).r;
			float s21 = tex2D(_MainTex, i.tex + float2( 0,     os.y)).r;
			float s22 = tex2D(_MainTex, i.tex + float2( os.x,  os.y)).r;

			float sobelX = s00 + 2 * s10 + s20 - s02 - 2 * s12 - s22;
			float sobelY = s00 + 2 * s01 + s02 - s20 - 2 * s21 - s22;

			float edgeSqr = (sobelX * sobelX + sobelY * sobelY);
			return edgeSqr > (_EdgeThreshold * _EdgeThreshold);
       	}
		float4 fragLine (v2f i) : COLOR
       	{
			const float2 SAMPLES[12] = {
				float2(-0.326212, -0.405805),
				float2(-0.840144, -0.073580),
				float2(-0.695914,  0.457137),
				float2(-0.203345,  0.620716),
				float2( 0.962340, -0.194983),
				float2( 0.473434, -0.480026),
				float2( 0.519456,  0.767022),
				float2( 0.185461, -0.893124),
				float2( 0.507431,  0.064425),
				float2( 0.896420,  0.412458),
				float2(-0.321940, -0.932615),
				float2(-0.791559, -0.597705),
			};
			float sum = tex2D(_MainTex, i.tex).r;
			for (int n = 0; n < 12; n++)
				sum += tex2D(_MainTex, i.tex + _SampleDist * SAMPLES[n]).r;
#ifdef WHITE_BOARD_1
			return (1 - _Hardness * sum) * _EdgeColor;
#endif
#ifdef WHITE_BOARD_2
			return _Hardness * sum * _EdgeColor;
#endif
		}
	ENDCG
	SubShader {
		ZTest Off Cull Off ZWrite Off Blend Off
	  	Fog { Mode off }  
		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment fragEdge
			ENDCG
		}
		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment fragLine
			#pragma multi_compile WHITE_BOARD_1 WHITE_BOARD_2
			ENDCG
		}
	}
	FallBack Off
}