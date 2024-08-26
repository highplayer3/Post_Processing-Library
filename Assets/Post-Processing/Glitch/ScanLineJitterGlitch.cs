using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ScanLineJitterGlitch : PostEffectsBase
{
	public Shader scanLineJitterGlitchShader;
	private Material scanLineJitterGlitchMaterial;
	public Material material
	{
		get
		{
			scanLineJitterGlitchMaterial = CheckShaderAndCreateMaterial(scanLineJitterGlitchShader, scanLineJitterGlitchMaterial);
			return scanLineJitterGlitchMaterial;
		}
	}

	[Range(0f, 25f)]
	public float frequency = 1f;
	[Range(0f, 5f)]
	public float jitterIntensity = 0.1f;
	[Range(0f, 1f)]
	public float threshold = 1f;
	

	void OnRenderImage(RenderTexture src, RenderTexture dest)
	{
		if (material != null)
		{
			material.SetFloat("_Frequency", frequency);
			material.SetFloat("_JitterIntensity", jitterIntensity);
			material.SetFloat("_Threshold", threshold);
			Graphics.Blit(src, dest, material);
		}
		else
		{
			Graphics.Blit(src, dest);
		}
	}
}
