using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GrainyBlur : PostEffectsBase
{

	public Shader grainyBlurShader;
	private Material grainyBlurMaterial;
	public Material material
	{
		get
		{
			grainyBlurMaterial = CheckShaderAndCreateMaterial(grainyBlurShader, grainyBlurMaterial);
			return grainyBlurMaterial;
		}
	}

	[Range(0f, 0.1f)]
	public float radius = 1;
	[Range(1, 10)]
	public int iteration = 1;

	void OnRenderImage(RenderTexture src, RenderTexture dest)
	{
		if (material != null)
		{
			material.SetFloat("_Radius", radius);
			material.SetInt("_Iteration", iteration);
			Graphics.Blit(src, dest, material);
		}
		else
		{
			Graphics.Blit(src, dest);
		}
	}
}