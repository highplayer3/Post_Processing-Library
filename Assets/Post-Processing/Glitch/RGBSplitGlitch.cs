using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RGBSplitGlitch : PostEffectsBase
{
	public Shader rgbSplitGlitchShader;
	private Material rgbSplitGlitchMaterial;
	public Material material
	{
		get
		{
			rgbSplitGlitchMaterial = CheckShaderAndCreateMaterial(rgbSplitGlitchShader, rgbSplitGlitchMaterial);
			return rgbSplitGlitchMaterial;
		}
	}

	[Range(0f, 1f)]
	public float fading = 1f;
	[Range(0f, 5f)]
	public float amount;
	[Range(0f, 10f)]
	public float speed;
	[Range(0f, 1f)]
	public float centerFading;
	[Range(0f, 100f)]
	public float timeX = 0f;
	[Range(0f, 5f)]
	public float rAmount;
	[Range(0f, 5f)]
	public float bAmount;


	void OnRenderImage(RenderTexture src, RenderTexture dest)
	{
		if (material != null)
		{
			material.SetFloat("_Fading", fading);
			material.SetFloat("_Amount", amount);
			material.SetFloat("_Speed", speed);
			material.SetFloat("_CenterFading", centerFading);
			material.SetFloat("_TimeX", timeX);
			material.SetFloat("_RAmount", rAmount);
			material.SetFloat("_BAmount", bAmount);
			Graphics.Blit(src, dest, material);
		}
		else
		{
			Graphics.Blit(src, dest);
		}
	}
}
