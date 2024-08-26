using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DirectionalBlur : PostEffectsBase
{

	public Shader directionalBlurShader;
	private Material directionalBlurMaterial;
	public Material material
	{
		get
		{
			directionalBlurMaterial = CheckShaderAndCreateMaterial(directionalBlurShader, directionalBlurMaterial);
			return directionalBlurMaterial;
		}
	}

	public Vector2 direction;
	[Range(1, 10)]
	public int iteration = 1;

	void OnRenderImage(RenderTexture src, RenderTexture dest)
	{
		if (material != null)
		{
			material.SetVector("_Direction", direction);
			material.SetInt("_Iteration", iteration);
			Graphics.Blit(src, dest, material);
		}
		else
		{
			Graphics.Blit(src, dest);
		}
	}
}