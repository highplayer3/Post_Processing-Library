using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EdgeDetection_DepthNormals : PostEffectsBase
{
	public enum EdgeChecker
	{
		DepthNormal,
		Normal,
		Depth
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

	[Range(0.0f, 1.0f)]
	public float edgeOnly = 0.0f;
	[Range(1, 3)]
	public int sampleRange = 1;
	[Range(0, 2)]
	public float sensitivityDepth = 1;
	[Range(0, 2)]
	public float sensitivityNormal = 1;
	public Color edgeColor;
	public Color backgroundColor;

	public EdgeChecker edgeChecker = EdgeChecker.DepthNormal;

    private void OnEnable()
    {
		GetComponent<Camera>().depthTextureMode |= DepthTextureMode.DepthNormals;
    }

	private void OnDisEnable()
	{
		GetComponent<Camera>().depthTextureMode &= ~DepthTextureMode.DepthNormals;
	}
	[ImageEffectOpaque]
	void OnRenderImage(RenderTexture src, RenderTexture dest)
	{
		if (material != null)
		{
			material.SetFloat("_EdgeOnly", edgeOnly);
			material.SetFloat("_SampleRange", sampleRange);
			material.SetColor("_EdgeColor", edgeColor);
			material.SetColor("_BackgroundColor", backgroundColor);
			material.SetVector("_Sensitivity", new Vector4(sensitivityNormal, sensitivityDepth, 0, 0));

			Graphics.Blit(src, dest, material, (int)edgeChecker);
		}
		else
		{
			Graphics.Blit(src, dest);
		}
	}
}