Shader "Post-Processing/GaussianBlur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BlurSize ("Blur Size", Float) = 1
    }

	CGINCLUDE
	#include "UnityCG.cginc"

	struct v2f 
	{
		float4 pos : SV_POSITION;
		half2 uv[5] : TEXCOORD0;//5x5�ĸ�˹��
	};

	sampler2D _MainTex;  
	half4 _MainTex_TexelSize;//���ش�С(512x512---->���ش�С:1/512)
	float _BlurSize;

	v2f vertBlurVertical(appdata_img v)
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);

		half2 uv = v.texcoord;

		/*��������Ĵ�����ͼ:
		----3
		----1
		----0
		----2
		----4
		*/
		o.uv[0] = uv;
		o.uv[1] = uv + float2(0.0,_MainTex_TexelSize.y * 1.0) * _BlurSize;
		o.uv[2] = uv - float2(0.0,_MainTex_TexelSize.y * 1.0) * _BlurSize;
		o.uv[3] = uv + float2(0.0,_MainTex_TexelSize.y * 2.0) * _BlurSize;
		o.uv[4] = uv - float2(0.0,_MainTex_TexelSize.y * 2.0) * _BlurSize;

		return o;
	}
	v2f vertBlurHorizontal(appdata_img v)
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);

		half2 uv = v.texcoord;
		/*�����������
			4 2 0 1 3
		*/
		o.uv[0] = uv;
		o.uv[1] = uv + float2(_MainTex_TexelSize.x * 1.0,0.0) * _BlurSize;
		o.uv[2] = uv - float2(_MainTex_TexelSize.x * 1.0,0.0) * _BlurSize;
		o.uv[3] = uv + float2(_MainTex_TexelSize.x * 2.0,0.0) * _BlurSize;
		o.uv[4] = uv - float2(_MainTex_TexelSize.x * 2.0,0.0) * _BlurSize;

		return o;
	}
	fixed4 fragBlur(v2f i) : SV_Target
	{
		//weight��Ӧ���������:0,1,2
		float weight[3] = {0.4026, 0.2442, 0.0545};//��˹�˾��кܸߵĶԳ��ԣ�5x5�ĸ�˹��ֻ��Ҫ�洢3��ֵ(ˮƽ����ֱһ����)

		fixed3 sum = tex2D(_MainTex,i.uv[0]).rgb * weight[0];

		for(int it = 1; it < 3; it++){
			sum += tex2D(_MainTex, i.uv[it]).rgb * weight[it];
			sum += tex2D(_MainTex, i.uv[2*it]).rgb * weight[it];
		}

		return fixed4(sum,1.0);
	}

	ENDCG


    SubShader 
	{
		ZTest Always Cull Off ZWrite Off
		Pass 
		{  
			Name "GAUSSIAN_BLUR_VERTICAL"
			CGPROGRAM  
			#pragma vertex vertBlurVertical 
			#pragma fragment fragBlur
			ENDCG
		}  
		Pass
		{
			Name "GAUSSIAN_BLUR_HORIZONTAL"
			CGPROGRAM
			#pragma vertex vertBlurHorizontal
			#pragma fragment fragBlur
			ENDCG
		}
	}
	Fallback Off
}
