Shader "Post-Processing/EdgeDetection"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _EdgePower ("Edge Power", Float) = 1.0
		_SampleRange ("Sample Range", Float) = 1.0
        _EdgeColor ("Edge Color", Color) = (1,1,1,1)
        _BackgroundColor ("BG Color", Color) = (0,0,0,1)
    }

	CGINCLUDE
	#include "UnityCG.cginc"

	struct v2f 
	{
		float4 pos : SV_POSITION;
		half2 uv_Roberts[5] : TEXCOORD0;
		half2 uv_Sobel[9] : TEXCOORD5;
	};

	sampler2D _MainTex;  
	half4 _MainTex_TexelSize;//纹素大小(512x512---->纹素大小:1/512)
	fixed _EdgePower,_SampleRange;
	fixed4 _EdgeColor,_BackgroundColor;

	//将RGB转化为灰度值(为什么需要转化？-因为边缘的定义就是像素点灰度变化剧烈的地方)
	fixed luminance(fixed4 color) {
		return  0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b;
    }

	half Sobel(v2f i) {
		//给出水平和垂直方向上的卷积核(Sobel)
		const half Gy[9] = { -1,  0,  1,
		                     -2,  0,  2,
		                     -1,  0,  1 };
		const half Gx[9] = { -1, -2, -1,
		                      0,  0,  0,
		                      1,  2,  1 };
		//分别对9个像素进行采样，计算它们的亮度值然后与卷积核Gx和Gy中对应的权值相乘叠加到梯度上
		half texColor;
		half edgeX = 0;
		half edgeY = 0;
		for (int it = 0; it < 9; it++) {
		    texColor = luminance(tex2D(_MainTex, i.uv_Sobel[it]));
		    edgeX += texColor * Gx[it];
		    edgeY += texColor * Gy[it];
		}
		//最终的edge计算，越小越可能是边缘点
		half edge = 1 - abs(edgeX) - abs(edgeY);
		return edge;
    }

	half Robert(v2f i)
	{
		const half Gx[4] =
		{
			-1, 0,
			 0, 1
		};
		const float Gy[4] =
		{
			0, -1,
			1,  0
		};
		half texColor;
        half edgeX = 0;
        half edgeY = 0;
        for (int it = 0; it < 4; it++) {
            texColor = luminance(tex2D(_MainTex, i.uv_Roberts[it]));
            edgeX += texColor * Gx[it];
            edgeY += texColor * Gy[it];
        }
        half edge = 1 - abs(edgeX) - abs(edgeY);
        return edge;
	}

	v2f vert_Sobel(appdata_img v) {
		v2f o;
		
		o.pos = UnityObjectToClipPos(v.vertex);
		
		half2 uv = v.texcoord;
		//获取该片元周围的9个领域纹理坐标
		o.uv_Sobel[0] = uv + _MainTex_TexelSize.xy * half2(-1,-1) * _SampleRange;
		o.uv_Sobel[1] = uv + _MainTex_TexelSize.xy * half2( 0,-1) * _SampleRange;
		o.uv_Sobel[2] = uv + _MainTex_TexelSize.xy * half2( 1,-1) * _SampleRange;
		o.uv_Sobel[3] = uv + _MainTex_TexelSize.xy * half2(-1, 0) * _SampleRange;
		o.uv_Sobel[4] = uv + _MainTex_TexelSize.xy * half2( 0, 0) * _SampleRange;
		o.uv_Sobel[5] = uv + _MainTex_TexelSize.xy * half2( 1, 0) * _SampleRange;
		o.uv_Sobel[6] = uv + _MainTex_TexelSize.xy * half2(-1, 1) * _SampleRange;
		o.uv_Sobel[7] = uv + _MainTex_TexelSize.xy * half2( 0, 1) * _SampleRange;
		o.uv_Sobel[8] = uv + _MainTex_TexelSize.xy * half2( 1, 1) * _SampleRange;

		return o;
	}

	fixed4 frag_Sobel(v2f i) : SV_Target {
		fixed4 col = tex2D(_MainTex,i.uv_Sobel[4]);
		float edge = pow(Sobel(i),_EdgePower);
		col.rgb = lerp(_EdgeColor,_BackgroundColor,edge);
		return col;
	}  

	v2f vert_Roberts (appdata_img v)
	{
		v2f o;

		o.pos = UnityObjectToClipPos(v.vertex);

		half2 uv = v.texcoord;
		o.uv_Roberts[0] = uv + half2(-1, -1) * _MainTex_TexelSize * _SampleRange;
		o.uv_Roberts[1] = uv + half2( 1, -1) * _MainTex_TexelSize * _SampleRange;
		o.uv_Roberts[2] = uv + half2(-1,  1) * _MainTex_TexelSize * _SampleRange;
		o.uv_Roberts[3] = uv + half2( 1,  1) * _MainTex_TexelSize * _SampleRange;
		o.uv_Roberts[4] = uv;
		return o;
	}
	
	fixed4 frag_Roberts (v2f i) : SV_Target
	{
		fixed4 col = tex2D(_MainTex, i.uv_Roberts[4]);
		float edge = pow(Robert(i),_EdgePower);
		col.rgb = lerp(_EdgeColor, _BackgroundColor, edge);
		return col;
	}

	ENDCG


    SubShader 
	{
		ZTest Always Cull Off ZWrite Off
		Pass 
		{  
			CGPROGRAM  
			#pragma vertex vert_Sobel 
			#pragma fragment frag_Sobel  
			ENDCG
		}  
		Pass
		{
			CGPROGRAM
			#pragma vertex vert_Roberts
			#pragma fragment frag_Roberts
			ENDCG
		}
	}
	Fallback Off
}
