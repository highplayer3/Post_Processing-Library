Shader "Post-Processing/Glitch/LineBlockGlitch"
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
        half _Frequency,_TimeX,_Amount,_Offset,_LineWidth,_Alpha;

        struct v2f
        {
            float4 pos : SV_POSITION;
            half2 uv : TEXCOORD0;
        };

        v2f vert(appdata_img v)
        {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv = v.texcoord;
            return o;
        }

        float randomNoise(float2 c)
        {
            return frac(sin(dot(c.xy,float2(12.9898,78.233))) * 43758.5453);
        }
        
        float3 rgb2yuv(float3 rgb)
	    {
	    	float3 yuv;
	    	yuv.x = dot(rgb, float3(0.299, 0.587, 0.114));
	    	yuv.y = dot(rgb, float3(-0.14713, -0.28886, 0.436));
	    	yuv.z = dot(rgb, float3(0.615, -0.51499, -0.10001));
	    	return yuv;
	    }
	    
	    float3 yuv2rgb(float3 yuv)
	    {
	    	float3 rgb;
	    	rgb.r = yuv.x + yuv.z * 1.13983;
	    	rgb.g = yuv.x + dot(float2(-0.39465, -0.58060), yuv.yz);
	    	rgb.b = yuv.x + yuv.y * 2.03211;
	    	return rgb;
	    }
        float trunc(float x, float num_levels)
        {
            return floor(x * num_levels) / num_levels;
        }

        float2 trunc(float2 x, float2 num_levels)
	    {
	    	return floor(x * num_levels) / num_levels;
	    }

        fixed4 frag(v2f i) : SV_Target
        {
            float2 uv = i.uv;

            half strength = 0.5 + 0.5 * cos(_TimeX * _Frequency);

            _TimeX *= strength;
            //	[1] �������ǿ���ݶ�����
		    float truncTime = trunc(_TimeX, 4.0);
		    float uv_trunc = randomNoise(trunc(uv.yy, float2(8, 8)) + 100.0 * truncTime);
		    float uv_randomTrunc = 6.0 * trunc(_TimeX, 24.0 * uv_trunc);

            // [2] ��������Ǿ��ȿ������
		    float blockLine_random = 0.5 * randomNoise(trunc(uv.yy + uv_randomTrunc, float2(8 * _LineWidth, 8 * _LineWidth)));
		    blockLine_random += 0.5 * randomNoise(trunc(uv.yy + uv_randomTrunc, float2(7, 7)));
		    blockLine_random = blockLine_random * 2.0 - 1.0;
		    blockLine_random = sign(blockLine_random) * saturate((abs(blockLine_random) - _Amount) / (0.4));
		    blockLine_random = lerp(0, blockLine_random, _Offset);

            float2 uv_blockLine = uv;
		    uv_blockLine = saturate(uv_blockLine + float2(0.1 * blockLine_random, 0));
            float4 blockLineColor = tex2D(_MainTex,abs(uv_blockLine));

            // [4] ��RGBת��YUV�ռ䣬����ɫ��ƫ��
		    // RGB -> YUV
		    float3 blockLineColor_yuv = rgb2yuv(blockLineColor.rgb);
		    // adjust Chrominance | ɫ��
		    blockLineColor_yuv.y /= 1.0 - 3.0 * abs(blockLine_random) * saturate(0.5 - blockLine_random);
		    // adjust Chroma | Ũ��
		    blockLineColor_yuv.z += 0.125 * blockLine_random * saturate(blockLine_random - 0.5);
		    float3 blockLineColor_rgb = yuv2rgb(blockLineColor_yuv);

            // [5] ��Դ����ͼ���л��
		    float4 sceneColor = tex2D(_MainTex, i.uv);
		    return lerp(sceneColor, float4(blockLineColor_rgb, blockLineColor.a), _Alpha);

            
            //return (blockLineColor_rgb,1);
            // fixed4(blockLine_random,blockLine_random,blockLine_random,1);
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
}
