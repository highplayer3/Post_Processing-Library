using UnityEngine;

namespace NprPaintFilter
{
	[RequireComponent(typeof(Camera))]
	public class CmykHalftone : MonoBehaviour
	{
		public Material m_Mat;
		[Range(0.1f, 1.2f)] public float m_Scale = 1f;
		[Range(0.1f, 8f)] public float m_Angle = 4f;
		[Range(1f, 8f)] public float m_Strength = 4f;

		void Update ()
		{
			m_Mat.SetFloat ("_Scale", m_Scale);
			m_Mat.SetFloat ("_Angle", m_Angle);
			m_Mat.SetFloat ("_Strength", m_Strength);
		}
		void OnRenderImage (RenderTexture src, RenderTexture dst)
		{
			Graphics.Blit (src, dst, m_Mat);
		}
	}
}