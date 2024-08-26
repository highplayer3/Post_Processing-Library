using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bloom_Plus : PostEffectsBase
{

	private const int PassExtractBright = 0;
	private const int PassKawaseBlur = 1;
	private const int PassBoxBlur = 2;
	private const int PassGaussianBlurV = 3;
	private const int PassGaussianBlurH = 4;
	private const int PassCombine = 5;

	public enum BloomBlurMode
    {
		KawaseBlur,
		BoxBlur,
		GaussianBlur
    }
	public Shader bloomShader;
	private Material bloomMaterial = null;
	public Material material
	{
		get
		{
			bloomMaterial = CheckShaderAndCreateMaterial(bloomShader, bloomMaterial);
			return bloomMaterial;
		}
	}
	[Header("Control the blur")]
	public bool iterationDownSample;//����ÿ�ε��������н�����
	public bool needUpSample;//������
	public BloomBlurMode blurMode = BloomBlurMode.GaussianBlur;
	// Blur iterations - larger number means more blur.
	[Range(0, 4)]
	public int iterations = 3;

	// Blur spread for each iteration - larger value means more blur
	[Range(0.2f, 3.0f)]
	public float blurDistance = 0.6f;
	private float _blurDistance;

	[Tooltip("Only valid when the Property(iterationDownSample) is false ")]
	//����������
	[Range(1, 8)]
	public int downSample = 2;

	[Space(5)]
	[Header("Control the brightness")]
	//��ֵ�����ڿ�����Щ���ڽ�������
	[Range(0.0f, 0.4f)]
	public float luminanceThreshold = 0.2f;
	public float intensity = 1f;
	public float lerpFactor = 1f;
	public Color bloomTint;

	void OnRenderImage(RenderTexture src, RenderTexture dest)
	{
		//��ȡ��������
		var brightTex = ExtractBright(src, src.width, src.height);

		//ģ��
		brightTex = BlurImage(src.width, src.height, brightTex);

		//���
		Combine(brightTex, src, dest);

	}
	/// <summary>
	/// ���ģ�����ͼ��
	/// </summary>
	/// <param name="brightTex"></param>
	/// <param name="src"></param>
	/// <param name="dest"></param>
	private void Combine(RenderTexture brightTex, RenderTexture src, RenderTexture dest)
	{
		material.SetTexture("_BrightTex", brightTex);
		material.SetFloat("_Intensity", intensity);
		material.SetFloat("_LerpFactor", lerpFactor);

		//���
		Graphics.Blit(src, dest, material, PassCombine);
		RenderTexture.ReleaseTemporary(brightTex);
	}

	/// <summary>
	/// ģ��ͼ��
	/// </summary>
	/// <param name="srcWidth"></param>
	/// <param name="srcHeight"></param>
	/// <param name="brightTex"></param>
	/// <returns></returns>
	private RenderTexture BlurImage(int srcWidth,int srcHeight,RenderTexture brightTex)
    {
		_blurDistance = blurDistance;
        for (int i = 0; i < iterations; i++)
        {
			brightTex = SingleBlurProcess(srcWidth, srcHeight, i, brightTex);
        }
        if (needUpSample)
        {
			//������
			_blurDistance = blurDistance;
            for (int i = iterations; i >= 1; i--)
            {
				brightTex = SingleBlurProcess(srcWidth, srcHeight, i, brightTex);
            }
        }
		return brightTex;
    }

	private RenderTexture SingleBlurProcess(int srcWidth,int srcHeight,int index,RenderTexture brightTex)
    {
		material.SetFloat("_BlurDistance", _blurDistance);

		if (blurMode == BloomBlurMode.KawaseBlur)
			_blurDistance *= 2;

		var tempTex = GetTexture(srcWidth, srcHeight, index);
		Graphics.Blit(brightTex, tempTex, material, (int)blurMode);
		RenderTexture.ReleaseTemporary(brightTex);
		brightTex = tempTex;

		//gaussianBlurÿ��ѭ����һ��pass
		if (blurMode == BloomBlurMode.GaussianBlur)
		{
			tempTex = GetTexture(srcWidth, srcHeight, index);
			Graphics.Blit(brightTex, tempTex, material, (int)blurMode + 1);
			RenderTexture.ReleaseTemporary(brightTex);
			brightTex = tempTex;
		}

		return brightTex;

	}

	/// <summary>
	/// ��ȡTexture�еĸ�������
	/// </summary>
	/// <param name="src"></param>
	/// <param name="width"></param>
	/// <param name="height"></param>
	/// <returns></returns>
	private RenderTexture ExtractBright(RenderTexture src,int width,int height)
    {
		var brightTex = RenderTexture.GetTemporary(width, height);
		material.SetFloat("_LuminanceThreshold", luminanceThreshold);
		material.SetColor("_BloomTint", bloomTint);
		//ʹ��material�ĵ�һ��Pass����ȡ����
        Graphics.Blit(src, brightTex, material, PassExtractBright);

		return brightTex;
    }

	/// <summary>
	/// ��ȡһ��RT�ķ�����װ
	/// </summary>
	/// <param name="rawWidth"></param>
	/// <param name="rawHeight"></param>
	/// <param name="index"></param>
	/// <returns></returns>
	private RenderTexture GetTexture(int rawWidth, int rawHeight, int index)
	{
		var width = rawWidth;
		var height = rawHeight;
		if (iterationDownSample)
		{
			width = rawWidth >> index;
			height = rawHeight >> index;
		}
		else
		{
			width = rawWidth >> downSample;
			height = rawHeight >> downSample;
		}

		var tex = RenderTexture.GetTemporary(width, height);
		tex.filterMode = FilterMode.Bilinear;

		return tex;
	}

}