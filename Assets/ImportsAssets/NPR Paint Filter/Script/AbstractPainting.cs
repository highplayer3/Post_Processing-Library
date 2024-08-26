using UnityEngine;

namespace NprPaintFilter
{
	[RequireComponent(typeof(Camera))]
	public class AbstractPainting : MonoBehaviour
	{
		public Material m_Mat;
		[Range(1f, 8f)] public float m_EdgeWeight = 2f;
		[Range(1f, 8f)] public float m_Brightness = 2f;

		void Update ()
		{
			m_Mat.SetFloat ("_EdgeWeight", m_EdgeWeight);
			m_Mat.SetFloat ("_Brightness", m_Brightness);
		}
		void OnRenderImage (RenderTexture src, RenderTexture dst)
		{
			Graphics.Blit (src, dst, m_Mat);
		}
	}
}