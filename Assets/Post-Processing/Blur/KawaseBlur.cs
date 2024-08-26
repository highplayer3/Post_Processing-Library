using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class KawaseBlur : PostEffectsBase
{

	public Shader kawaseBlurShader;
	private Material kawaseBlurMaterial;
	public Material material
	{
		get
		{
			kawaseBlurMaterial = CheckShaderAndCreateMaterial(kawaseBlurShader, kawaseBlurMaterial);
			return kawaseBlurMaterial;
		}
	}

	[Range(0,5)]
	public int iteration = 3;

	[Range(0.0f, 3.0f)]
	public float blurSpread = 1.0f;

	[Range(1, 8)]
	public int downSample = 2;

	void OnRenderImage(RenderTexture src, RenderTexture dest)
	{
		if (material != null)
		{
			//��Ҫ����Pass,����Ҫ��RTȥ�洢�м���
			int rtW = src.width / downSample;
			int rtH = src.height / downSample;

			RenderTexture tempBuffer0 = RenderTexture.GetTemporary(rtW, rtH, 0);
			tempBuffer0.filterMode = FilterMode.Bilinear;

			Graphics.Blit(src, tempBuffer0);

            for (int i = 0; i < iteration; i++)
            {
				material.SetFloat("_BlurSize", (i+1) * blurSpread);

				RenderTexture tempBuffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);

				Graphics.Blit(tempBuffer0, tempBuffer1, material);//ʹ�õ�һ��Passȥ������������buffer1
				RenderTexture.ReleaseTemporary(tempBuffer0);//�ͷ���ʱBuffer0
				tempBuffer0 = tempBuffer1;//�ͷ�0������������0������ָ��1������
				
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