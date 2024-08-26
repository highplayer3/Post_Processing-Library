// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "NPR Paint Filter/Blackboard Color" {
	Properties {}
	SubShader {
		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			struct v2f
			{
				float4 pos : POSITION;
			};
			v2f vert (appdata_base v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				return o;
			}
			fixed4 frag (v2f i) : SV_Target
			{
				return 1.0;
			}
			ENDCG
		}
	}
	FallBack Off
}