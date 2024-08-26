using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// 使用累计缓存的Motion Blur
/// </summary>
public class MotionBlur : PostEffectsBase
{

	public Shader motionBlurShader;
	private Material motionBlurMaterial;
	public Material material
	{
		get
		{
			motionBlurMaterial = CheckShaderAndCreateMaterial(motionBlurShader, motionBlurMaterial);
			return motionBlurMaterial;
		}
	}

	[Range(0f, 1f)]
	public float blurAmount = 0.5f;

	private RenderTexture accumulationTexture;

	//脚本不执行时调用，用于重新计算模糊图像
    private void OnDisable()
    {
		DestroyImmediate(accumulationTexture);
    }


    void OnRenderImage(RenderTexture src, RenderTexture dest)
	{
		if (material != null)
		{
			//创建累计缓存
			if(accumulationTexture == null || accumulationTexture.width != src.width || accumulationTexture.height != src.height)
            {
				DestroyImmediate(accumulationTexture);
				accumulationTexture = new RenderTexture(src.width, src.height,0);
				accumulationTexture.hideFlags = HideFlags.HideAndDontSave;
				Graphics.Blit(src, accumulationTexture);
            }

			accumulationTexture.MarkRestoreExpected();
			material.SetFloat("_BlurAmount", 1.0f - blurAmount);

			Graphics.Blit(src, accumulationTexture, material);
			Graphics.Blit(accumulationTexture, dest);
		}
		else
		{
			Graphics.Blit(src, dest);
		}
	}
}