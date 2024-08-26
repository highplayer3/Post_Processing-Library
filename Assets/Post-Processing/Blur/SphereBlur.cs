using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SphereBlur : PostEffectsBase
{

	public Shader sphereBlurShader;
	private Material sphereBlurMaterial;
	public Material material
	{
		get
		{
			sphereBlurMaterial = CheckShaderAndCreateMaterial(sphereBlurShader, sphereBlurMaterial);
			return sphereBlurMaterial;
		}
	}

	[Range(0f,20f)]
	public float radius = 1f;
	[Range(0f, 5f)]
	public float pow;

	void OnRenderImage(RenderTexture src, RenderTexture dest)
	{
		if (material != null)
		{
			material.SetFloat("_Radius", radius);
			material.SetFloat("_Pow", pow);
			Graphics.Blit(src, dest, material);
		}
		else
		{
			Graphics.Blit(src, dest);
		}
	}
}