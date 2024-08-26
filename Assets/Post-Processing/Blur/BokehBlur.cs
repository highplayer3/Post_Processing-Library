using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BokehBlur : PostEffectsBase
{

	public Shader bokehBlurShader;
	private Material bokehBlurMaterial;
	public Material material
	{
		get
		{
			bokehBlurMaterial = CheckShaderAndCreateMaterial(bokehBlurShader, bokehBlurMaterial);
			return bokehBlurMaterial;
		}
	}

	[Range(0,10)]
	public float rotateDistance = 1;

	[Range(0.0f,10f)]
	public float radius = 1.0f;

	[Range(1, 10)]
	public int sampleCount = 10;

	void OnRenderImage(RenderTexture src, RenderTexture dest)
	{
		if (material != null)
		{
			material.SetFloat("_RotateDistance", rotateDistance);
			material.SetInt("_SampleCount", sampleCount);
			material.SetFloat("_Radius", radius);

			Graphics.Blit(src, dest, material);
		}
		else
		{
			Graphics.Blit(src, dest);
		}
	}
}