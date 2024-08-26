Shader "Post-Processing/Glitch/RGBSplitGlitch"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        CGINCLUDE
        #include "UnityCG.cginc"

        #pragma shader_feature USING_FREQUENCY_INFINITE

        sampler2D _MainTex;
        half4 _MainTex_TexelSize;
        half _JitterIntensity,_Threshold,_Frequency;

        struct v2f
        {
            float4 pos : SV_POSITION;
            half2 uv : TEXCOORD0;
        };

        float randomNoise(float x, float y)
	    {
	    	return frac(sin(dot(float2(x, y), float2(12.9898, 78.233))) * 43758.5453);
	    }

        v2f vert(appdata_img v)
        {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv = v.texcoord;
            return o;
        }

        half4 frag(v2f i) : SV_Target
        {
            half strength = 0;
            #if USING_FREQUENCY_INFINITE
			    strength = 1;
		    #else
			    strength = 0.5 + 0.5 * cos(_Time.y * _Frequency);
		    #endif

            float jitter = randomNoise(i.uv.y,_Time.x) * 2 - 1;
            jitter *= step(_Threshold,abs(jitter)) * _JitterIntensity * strength;

            half4 col = tex2D(_MainTex,frac(i.uv + float2(jitter,0)));

            return col;
        }
        ENDCG

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            ENDCG
        }
    }
    FallBack Off
}
