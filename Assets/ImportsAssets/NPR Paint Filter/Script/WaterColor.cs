using UnityEngine;

namespace NprPaintFilter
{
	[RequireComponent(typeof(Camera))]
	public class WaterColor : MonoBehaviour
	{
		[Header("Wobble")]
		public Texture2D m_WobbleTex;
		public float m_WobbleScale = 1f;
		[Range(0.001f, 0.006f)] public float m_WobblePower = 0.003f;
		[Header("Edge")]
		public float m_EdgeSize = 1f;
		public float m_EdgePower = 3f;
		[Header("Paper")]
		public Texture2D m_Paper1;
		public float m_Paper1Power = 1f;
		public Texture2D m_Paper2;
		public float m_Paper2Power = 1f;
		[Header("Material")]
		public Material m_Mat;

		void OnRenderImage (RenderTexture src, RenderTexture dst)
		{
			m_Mat.SetTexture ("_WobbleTex", m_WobbleTex);
			m_Mat.SetFloat ("_WobbleScale", m_WobbleScale);
			m_Mat.SetFloat ("_WobblePower", m_WobblePower);
			m_Mat.SetFloat ("_EdgeSize", m_EdgeSize);
			m_Mat.SetFloat ("_EdgePower", m_EdgePower);

			RenderTexture rt0 = RenderTexture.GetTemporary (src.width, src.height, 0, RenderTextureFormat.ARGB32);
			RenderTexture rt1 = RenderTexture.GetTemporary (src.width, src.height, 0, RenderTextureFormat.ARGB32);

			Graphics.Blit (src, rt0, m_Mat, 0);

			m_Mat.SetTexture ("_PaperTex", m_Paper1);
			m_Mat.SetFloat ("_PaperPower", m_Paper1Power);
			Graphics.Blit (rt0, rt1, m_Mat, 1);
			Graphics.Blit (rt1, rt0, m_Mat, 2);

			m_Mat.SetTexture ("_PaperTex", m_Paper2);
			m_Mat.SetFloat ("_PaperPower", m_Paper2Power);
			Graphics.Blit (rt0, rt1, m_Mat, 1);
			Graphics.Blit (rt1, dst, m_Mat, 2);

			RenderTexture.ReleaseTemporary (rt0);
			RenderTexture.ReleaseTemporary (rt1);
		}
	}
}
