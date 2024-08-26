using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ChromaticAbberation : PostEffectsBase
{

	public Shader briSatConShader;
	private Material briSatConMaterial;
	public Material material
	{
		get
		{
			briSatConMaterial = CheckShaderAndCreateMaterial(briSatConShader, briSatConMaterial);
			return briSatConMaterial;
		}
	}

	[Range(-0.5f, 0.5f)]
	public float chromaticFactor;//Chromatic Abberation
	[Range(0, 2)]
	public float chromaticRegionFactor;

	void OnRenderImage(RenderTexture src, RenderTexture dest)
	{
		if (material != null)
		{
			material.SetFloat("_ChromaticFactor", chromaticFactor);
			material.SetFloat("_ChromaticRegionFactor", chromaticRegionFactor);
			Graphics.Blit(src, dest, material);
		}
		else
		{
			Graphics.Blit(src, dest);
		}
	}
}