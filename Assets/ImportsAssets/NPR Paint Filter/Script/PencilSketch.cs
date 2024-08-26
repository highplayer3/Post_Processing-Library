using UnityEngine;

namespace NprPaintFilter
{
	[RequireComponent(typeof(Camera))]
	public class PencilSketch : MonoBehaviour
	{
		public Material m_Mat;
		public Color m_Color = new Color (0.4f, 0.075f, 0.075f, 1f);
		[Range(-0.5f, 0.03f)] public float m_Strength = 0.02f;
		[Range(1f, 5f)] public float m_Offset = 2f;

		void OnRenderImage (RenderTexture src, RenderTexture dst)
		{
			m_Mat.SetFloat ("_Strength", m_Strength);
			m_Mat.SetFloat ("_Offset", m_Offset);
			m_Mat.SetColor ("_LineColor", m_Color);
			Graphics.Blit (src, dst, m_Mat);
		}
	}
}
