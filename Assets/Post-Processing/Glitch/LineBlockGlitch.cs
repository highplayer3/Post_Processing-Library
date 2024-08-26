using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LineBlockGlitch : PostEffectsBase
{
	public Shader lineBlockGlitchShader;
	private Material lineBlockGlitchMaterial;
	public Material material
	{
		get
		{
			lineBlockGlitchMaterial = CheckShaderAndCreateMaterial(lineBlockGlitchShader, lineBlockGlitchMaterial);
			return lineBlockGlitchMaterial;
		}
	}

	[Range(0f, 25f)]
	public float frequency = 1f;
	[Range(0f, 100f)]
	public float timeX = 0f;
	[Range(0f, 1f)]
	public float amount = 0.5f;
	[Range(0f, 1f)]
	public float offset = 1f;
	[Range(0.1f, 10f)]
	public float lineWidth = 1f;
	[Range(0f, 1f)]
	public float speed = 0.8f;
	[Range(0f, 1f)]
	public float alpha = 1f;
	

	void OnRenderImage(RenderTexture src, RenderTexture dest)
	{
		if (material != null)
		{
			material.SetFloat("_Frequency", frequency);
			material.SetFloat("_Amount", amount);
			material.SetFloat("_Speed", speed);
			material.SetFloat("_Offset", offset);
			material.SetFloat("_TimeX", timeX);
			material.SetFloat("_LineWidth", lineWidth);
			material.SetFloat("_Alpha", alpha);
			Graphics.Blit(src, dest, material);
		}
		else
		{
			Graphics.Blit(src, dest);
		}
	}
}
