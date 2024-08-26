Shader "Post-Processing/Artistic/OldTV"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        CGINCLUDE
        #include "UnityCG.cginc"
        
        sampler2D _MainTex;

        float _Expand,_NoiseIntensity;
        int _StripeIntensity;

        float simpleNoise(float2 uv)
        {
            return frac(sin(dot(uv,float2(12.9898,78.233))) * 43758.5453);
        }

        half4 frag(v2f_img i) : SV_Target
        {
            //实现屏幕的曲率
            float d2 = dot(i.uv - half2(0.5,0.5), i.uv - half2(0.5,0.5));
            half2 coord = (i.uv - half2(0.5,0.5)) * (_Expand + d2 * (1 - _Expand)) + half2(0.5,0.5);
            half4 color = tex2D(_MainTex,coord);
            //添加噪点效果
            float n = simpleNoise(coord.xy * _Time.x);
            half3 result = color.rgb * (1 - _NoiseIntensity) + _NoiseIntensity * n;
            //添加条纹效果(用弯曲后的coord.y的坐标来实现)
            half2 sc = half2((sin(coord.y * _StripeIntensity) + 1) / 2, (cos(coord.y * _StripeIntensity) + 1) / 2);
            result += color.rgb * sc.xyx;

            return half4(result, color.a);
        }
        ENDCG

        Pass
        {
            ZTest Always Cull Off ZWrite Off

            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag
            ENDCG
        }
    }
    FallBack Off
}
