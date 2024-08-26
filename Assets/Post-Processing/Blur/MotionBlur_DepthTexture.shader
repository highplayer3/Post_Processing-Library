Shader "Post-Processing/MotionBlur_DepthTexture"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag


            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _CameraDepthTexture;

            float4x4 _CurrentViewProjectionInverseMatrix;
            float4x4 _PreviousViewProjectionMatrix;

            half _BlurSize;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                //ndc�µ����
                float ndcDepth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);
                //��ԭndc�µ�����
                float4 ndcPos = float4(i.uv.x * 2 - 1, i.uv.y * 2 - 1, ndcDepth * 2 - 1, 1);
                //��ndc���껹ԭ��������
                float4 worldPos = mul(_CurrentViewProjectionInverseMatrix, ndcPos);
                worldPos = worldPos / worldPos.w;
                //�ø������������ǰһ֡��ͶӰ�ü����󣬻��ǰһ֡��ndc����
                float4 previousNdcPos = mul(_PreviousViewProjectionMatrix, worldPos);
                previousNdcPos = previousNdcPos / previousNdcPos.w;

                //�����ٶ�
                float2 speed = (ndcPos.xy - previousNdcPos.xy) / 2.0f;
                float4 col = tex2D(_MainTex, i.uv);
                fixed2 uv=i.uv;
                for (int i = 0; i < 10; i++)
                {
                    uv+= speed*_BlurSize;
                    float4 color = tex2D(_MainTex, uv);
                    col += color;
                }
                col /= 10;

                return col;
            }
            ENDCG
        }
    }
    FallBack Off
}
