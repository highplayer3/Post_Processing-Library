using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RadialBlur : PostEffectsBase
{

	public Shader radialBlurShader;
	private Material radialBlurMaterial;
	public Material material
	{
		get
		{
			radialBlurMaterial = CheckShaderAndCreateMaterial(radialBlurShader, radialBlurMaterial);
			return radialBlurMaterial;
		}
	}

	[Range(0f, 5f)]
	public float blurRadius = 1;
	[Range(1, 10)]
	public int iteration = 1;

	[Range(0f, 1f)]
	public float radialCenterX = 0.5f;
	[Range(0f, 1f)]
	public float radialCenterY = 0.5f;

	void OnRenderImage(RenderTexture src, RenderTexture dest)
	{
		if (material != null)
		{
			material.SetFloat("_BlurRadius", blurRadius);
			material.SetInt("_Iteration", iteration);
			material.SetVector("_RadialCenter", new Vector2(radialCenterX, radialCenterY));
			Graphics.Blit(src, dest, material);
		}
		else
		{
			Graphics.Blit(src, dest);
		}
	}
}