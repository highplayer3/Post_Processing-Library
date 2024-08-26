Shader "Post-Processing/Artistic/OilPaintEffect"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ScreenResolution("_ScreenResolution", Vector) = (0., 0., 0., 0.)
		_ResolutionValue("_ResolutionValue", Range(0.0, 5.0)) = 1.0
		_Radius("_Radius", Range(0.0, 5.0)) = 2.0
        _Distortion ("Distortion", Range(0.0,1.0)) = 0.3
    }
    SubShader
    {
        Pass
        {
            ZTest Always Cull Off ZWrite Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct a2v
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                half2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            uniform sampler2D _MainTex;
            uniform int _Radius;
            uniform float4 _ScreenResolution;
            uniform float _Distortion,_ResolutionValue;

            v2f vert (a2v v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 src_size = float2(_ResolutionValue / _ScreenResolution.x,_ResolutionValue / _ScreenResolution.y);

                float n = float((_Radius + 1) * (_Radius + 1));

                //【4】定义一些参数
				float3 m0 = 0.0;  float3 m1 = 0.0;
				float3 s0 = 0.0;  float3 s1 = 0.0;
				float3 c;
                
                for(int j = -_Radius; j <= 0; ++j){
                    for(int k = -_Radius; k <= 0; ++k){
                        c = tex2D(_MainTex,i.uv + float2(k,j) * src_size).rgb;
                        m0 += c;
                        s0 += c * c;
                    }
                }

                for (int j = 0; j <= _Radius; ++j)
				{
					for (int k = 0; k <= _Radius; ++k)
					{
						c = tex2D(_MainTex, i.uv + float2(k, j) * src_size).rgb; 
						m1 += c;
						s1 += c * c;
					}
				}
                //【7】定义参数，准备计算最终的颜色值
				float4 finalFragColor = 0.;
				float min_sigma2 = 1e+2;
 
				//【8】根据m0和s0，第一次计算finalFragColor的值
				m0 /= n;
				s0 = abs(s0 / n - m0 * m0);
 
				float sigma2 = s0.r + s0.g + s0.b;
				if (sigma2 < min_sigma2) 
				{
					min_sigma2 = sigma2;
					finalFragColor = float4(m0, 1.0);
				}
 
				//【9】根据m1和s1，第二次计算finalFragColor的值
				m1 /= n;
				s1 = abs(s1 / n - m1 * m1);
 
				sigma2 = s1.r + s1.g + s1.b;
				if (sigma2 < min_sigma2) 
				{
					min_sigma2 = sigma2;
					finalFragColor = float4(m1, 1.0);
				}
 
				//【10】返回最终的颜色值
				return finalFragColor;
            }
            ENDCG
        }
    }
}
