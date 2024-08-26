Shader "Post-Processing/Artistic/OilPaintEffect"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        //��װ�ı���ֵ
	    _Params("PixelNumPerRow (X) Ratio (Y)", Vector) = (80, 1, 1, 1.5)
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
            half4 _Params;

            v2f vert (a2v v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                return o;
            }

            //�������ػ��������Զ��庯��PixelateOperation
			half4 PixelateOperation(sampler2D tex, half2 uv, half scale, half ratio)
			{
				//��1������ÿ�����ؿ�ĳߴ�
				half PixelSize = 1.0 / scale;
				//��2��ȡ������ÿ�����ؿ������ֵ��ceil�������������������ȡ��
				half coordX=PixelSize * ceil(uv.x / PixelSize);
				half coordY = (ratio * PixelSize)* ceil(uv.y / PixelSize / ratio);
				//��3���������ֵ
				half2 coord = half2(coordX,coordY);
				//��4����������ֵ
				return half4(tex2D(tex, coord).xyzw);
			}


            fixed4 frag (v2f i) : SV_Target
            {
                return PixelateOperation(_MainTex,i.uv,_Params.x,_Params.y);
            }
            ENDCG
        }
    }
}
