using UnityEngine;

namespace NprPaintFilter
{
	[RequireComponent(typeof(Camera))]
	public class BluePrint : MonoBehaviour
	{
		public Material m_Mat;
		public Texture2D m_BgTex;
		public Color m_PencilColor = Color.white;
		public Color m_BgColor = new Color (0.175f, 0.402f, 0.687f, 1f);
		[Range(0.0001f, 0.0022f)] public float m_Size = 0.0008f;
		[Range(1, 64)] public float m_PencilIntensity = 32f;
		[Range(0, 2)] public float m_AnimSpeed = 1f;
		[Range(0, 0.2f)] public float m_AnimIntensity = 0.08f;
		[Range(0, 1)] public float m_Vignette = 0.5f;
		[Range(0, 1)] public float m_FadePaper2Bg = 0.2f;
		[Range(0, 1)] public float m_Fade2Orig = 1f;
		float m_TimeCustom = 1f;

		void Update ()
		{
			m_TimeCustom += Time.deltaTime;
			if (m_TimeCustom > 100f)  m_TimeCustom = 0f;
			m_Mat.SetFloat ("_TimeCustom", m_TimeCustom);
			m_Mat.SetColor ("_PencilColor", m_PencilColor);
			m_Mat.SetFloat ("_Size", m_Size);
			m_Mat.SetFloat ("_PencilIntensity", m_PencilIntensity);
			m_Mat.SetFloat ("_AnimSpeed", m_AnimSpeed);
			m_Mat.SetFloat ("_AnimIntensity", m_AnimIntensity);
			m_Mat.SetFloat ("_Vignette", m_Vignette);
			m_Mat.SetFloat ("_FadePaper2Bg", m_FadePaper2Bg);
			m_Mat.SetFloat ("_Fade2Orig",m_Fade2Orig);
			m_Mat.SetColor ("_BgColor", m_BgColor);
			m_Mat.SetTexture ("_BgTex", m_BgTex);
		}
		void OnRenderImage (RenderTexture src, RenderTexture dst)
		{
			Graphics.Blit (src, dst, m_Mat);
		}
	}
}