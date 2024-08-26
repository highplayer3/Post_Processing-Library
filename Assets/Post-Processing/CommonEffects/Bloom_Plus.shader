Shader "Post-Processing/Bloom_Plus"
{
    Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
	}
	SubShader {
		ZTest Always Cull Off ZWrite Off

		CGINCLUDE
		#include "UnityCG.cginc"
		
		sampler2D _MainTex;
		half4 _MainTex_TexelSize;
		sampler2D _BrightTex;
		float _LuminanceThreshold;
		float _BlurDistance,_Intensity,_LerpFactor;
		fixed4 _BloomTint;
		
		struct v2f
        {
            float2 uv : TEXCOORD0;
            float4 vertex : SV_POSITION;
        };

        struct v2f2
        {
            float4 vertex : SV_POSITION;
            half2 uv[5]:TEXCOORD0;
        };

		v2f vert(appdata_img v)
        {
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.uv = v.texcoord;
            return o;
        }

        fixed4 frag(v2f i) : SV_Target
        {
            fixed4 col = tex2D(_MainTex, i.uv);
            return col * step(_LuminanceThreshold, Luminance(col)) * _BloomTint;
        }
        //kawaseBlur
		fixed4 kawaseBlur(v2f i) : SV_Target
        {
            fixed4 col = tex2D(_MainTex, i.uv + fixed2(0.5, 0.5) * _BlurDistance * _MainTex_TexelSize.xy) * 0.25;
            col += tex2D(_MainTex, i.uv + fixed2(-0.5, -0.5) * _BlurDistance * _MainTex_TexelSize.xy) * 0.25;
            col += tex2D(_MainTex, i.uv + fixed2(0.5, -0.5) * _BlurDistance * _MainTex_TexelSize.xy) * 0.25;
            col += tex2D(_MainTex, i.uv + fixed2(-0.5, 0.5) * _BlurDistance * _MainTex_TexelSize.xy) * 0.25;

            return col;
        }
        //Box Blur
        fixed4 boxBlur(v2f i) : SV_Target
        {
            fixed4 col = tex2D(_MainTex, i.uv + fixed2(1, 0) * _MainTex_TexelSize.xy * _BlurDistance) * 0.25;
            col += tex2D(_MainTex, i.uv + fixed2(-1, 0) * _MainTex_TexelSize.xy * _BlurDistance) * 0.25;
            col += tex2D(_MainTex, i.uv + fixed2(0, 1) * _MainTex_TexelSize.xy * _BlurDistance) * 0.25;
            col += tex2D(_MainTex, i.uv + fixed2(0, -1) * _MainTex_TexelSize.xy * _BlurDistance) * 0.25;

            return col;
        }
		
		v2f2 vertV(appdata_img v)
        {
            v2f2 o;
            o.vertex = UnityObjectToClipPos(v.vertex);

            o.uv[0] = v.texcoord + float2(0, _MainTex_TexelSize.y * -3.2307692308 * _BlurDistance);
            o.uv[1] = v.texcoord + float2(0, _MainTex_TexelSize.y * -1.3846153846 * _BlurDistance);
            o.uv[2] = v.texcoord;
            o.uv[3] = v.texcoord + float2(0, _MainTex_TexelSize.y * 1.3846153846 * _BlurDistance);
            o.uv[4] = v.texcoord + float2(0, _MainTex_TexelSize.y * 3.2307692308 * _BlurDistance);

            return o;
        }

        v2f2 vertH(appdata_img v)
        {
            v2f2 o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.uv[0] = v.texcoord + float2(_MainTex_TexelSize.x * -3.2307692308 * _BlurDistance, 0);
            o.uv[1] = v.texcoord + float2(_MainTex_TexelSize.x * -1.3846153846 * _BlurDistance, 0);
            o.uv[2] = v.texcoord;
            o.uv[3] = v.texcoord + float2(_MainTex_TexelSize.x * 1.3846153846 * _BlurDistance, 0);
            o.uv[4] = v.texcoord + float2(_MainTex_TexelSize.x * 3.2307692308 * _BlurDistance, 0);

            return o;
        }

        fixed4 gaussianBlur(v2f2 i) : SV_Target
        {
            fixed3 sum = tex2D(_MainTex, i.uv[0]).rgb * 0.0702702703;
            sum += tex2D(_MainTex, i.uv[1]).rgb * 0.3162162162;
            sum += tex2D(_MainTex, i.uv[2]).rgb * 0.2270270270;
            sum += tex2D(_MainTex, i.uv[3]).rgb * 0.3162162162;
            sum += tex2D(_MainTex, i.uv[4]).rgb * 0.0702702703;

            return fixed4(sum, 1);
        }

        fixed4 combine(v2f i) : SV_Target
        {
            fixed4 rawColor = tex2D(_MainTex, i.uv);
            fixed4 brightColor = tex2D(_MainTex, i.uv) + tex2D(_BrightTex, i.uv) * _Intensity;
            return lerp(rawColor, brightColor, _LerpFactor);
        }
		
		ENDCG
		
		//提取高亮区域
		Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            ENDCG
        }
        //kawaseBlur模糊处理
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment kawaseBlur
            ENDCG
        }
        //Box Blur模糊处理
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment boxBlur
            ENDCG
        }
        //gaussianBlur模糊处理-垂直
        Pass
        {
            CGPROGRAM
            #pragma vertex vertV
            #pragma fragment gaussianBlur
            ENDCG
        }
        //同上-水平
        Pass
        {
            CGPROGRAM
            #pragma vertex vertH
            #pragma fragment gaussianBlur
            ENDCG
        }
        //混合模糊后的图像和原图像
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment combine
            ENDCG
        }

	}
	FallBack Off
}
