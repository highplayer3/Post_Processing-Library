Shader "Post-Processing/Artistic/OilPaintEffect"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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

            sampler2D _MainTex;
            int _PixelSize;
            int _AddStrip;


            v2f vert (a2v v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                return o;
            }

            half2 stitch(half2 uv)
            {
                half2 screenPos = floor(uv * _ScreenParams.xy);
                half2 reminder;
                reminder.y = (screenPos.y - screenPos.x) % _PixelSize;
                reminder.x = (screenPos.y + screenPos.x) % _PixelSize;
                return reminder;
            }

            half4 pixel(half2 uv)
            {
                half2 screenPos = floor(uv * _ScreenParams.xy / _PixelSize) * _PixelSize;
                return tex2D(_MainTex, screenPos / _ScreenParams.xy);
            }



            fixed4 frag (v2f i) : SV_Target
            {
                half2 reminder = stitch(i.uv);
                half4 color = pixel(i.uv);
                return (reminder.y == 0 || reminder.x == 0)&&_AddStrip==1 ? half4(0, 0, 0, 1) : color;

            }
            ENDCG
        }
    }
}
