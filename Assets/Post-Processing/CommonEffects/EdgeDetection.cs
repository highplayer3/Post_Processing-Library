using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EdgeDetection : PostEffectsBase
{
	public enum EdgeOperator
	{
		Sobel = 0,
		Roberts = 1,
	}

	public Shader edgeDetectShader;
	private Material edgeDetectMaterial = null;
	public Material material
	{
		get
		{
			edgeDetectMaterial = CheckShaderAndCreateMaterial(edgeDetectShader, edgeDetectMaterial);
			return edgeDetectMaterial;
		}
	}

	[Range(0.0f, 10.0f)]
	public float edgePower = 0.0f;
	[Range(1, 5)]
	public int sampleRange = 1;
	public Color edgeColor;
	public Color backgroundColor;

	public EdgeOperator edgeOperator = EdgeOperator.Sobel;

	void OnRenderImage(RenderTexture src, RenderTexture dest)
	{
		if (material != null)
		{
			material.SetFloat("_EdgePower", edgePower);
			material.SetFloat("_SampleRange", sampleRange);
			material.SetColor("_EdgeColor", edgeColor);
			material.SetColor("_BackgroundColor", backgroundColor);

			Graphics.Blit(src, dest, material, (int)edgeOperator);
		}
		else
		{
			Graphics.Blit(src, dest);
		}
	}
}