using UnityEngine;

namespace NprPaintFilter
{
	[RequireComponent(typeof(Camera))]
	public class PencilDot : MonoBehaviour
	{
		public Material m_Mat;
		[Range(6f, 9.7f)] public float m_Thickness = 9f;

		void Update ()
		{
			m_Mat.SetFloat ("_Thickness", m_Thickness);
		}
		void OnRenderImage (RenderTexture src, RenderTexture dst)
		{
			Graphics.Blit (src, dst, m_Mat);
		}
	}
}