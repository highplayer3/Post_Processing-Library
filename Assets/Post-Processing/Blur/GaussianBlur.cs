using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GaussianBlur : PostEffectsBase
{

	public Shader gaussianBlurShader;
	private Material gaussianBlurMaterial;
	public Material material
	{
		get
		{
			gaussianBlurMaterial = CheckShaderAndCreateMaterial(gaussianBlurShader, gaussianBlurMaterial);
			return gaussianBlurMaterial;
		}
	}

	[Range(0,4)]
	public int iteration = 3;

	[Range(0.0f, 3.0f)]
	public float blurSpread = 1.0f;

	[Range(1, 8)]
	public int downSample = 2;

	void OnRenderImage(RenderTexture src, RenderTexture dest)
	{
		if (material != null)
		{
			//需要两个Pass,所以要用RT去存储中间结果
			int rtW = src.width / downSample;
			int rtH = src.height / downSample;

			RenderTexture tempBuffer0 = RenderTexture.GetTemporary(rtW, rtH, 0);
			tempBuffer0.filterMode = FilterMode.Bilinear;

			Graphics.Blit(src, tempBuffer0);

            for (int i = 0; i < iteration; i++)
            {
				material.SetFloat("_BlurSize", 1.0f + i * blurSpread);

				RenderTexture tempBuffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);

				Graphics.Blit(tempBuffer0, tempBuffer1, material, 0);//使用第一个Pass去处理，处理结果在buffer1
				RenderTexture.ReleaseTemporary(tempBuffer0);//释放临时Buffer0
				tempBuffer0 = tempBuffer1;//释放0缓冲区，再让0缓冲区指向1缓冲区
				tempBuffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);//1缓冲区再重新申请来完成交替

				Graphics.Blit(tempBuffer0, tempBuffer1, material, 1);//此时Buffer1中存储的是一次高斯模糊后的图像
				RenderTexture.ReleaseTemporary(tempBuffer0);
				tempBuffer0 = tempBuffer1;
            }
			Graphics.Blit(tempBuffer0, dest);
			RenderTexture.ReleaseTemporary(tempBuffer0);
		}
		else
		{
			Graphics.Blit(src, dest);
		}
	}
}