using UnityEngine;

namespace NprPaintFilter
{
	[RequireComponent(typeof(Camera))]
	public class OilPaint : MonoBehaviour
	{
		public Material m_Mat;
		[Range(1, 4)] public int m_Pass = 3;
		[Range(0.1f, 3f)] public float m_Resolution = 0.9f;
		public float m_EdgeSize = 1f;
		public float m_EdgePower = 3f;
		public enum EType { Custom = 0, Type1, Type2, Type3 };
		public EType m_Fx = EType.Custom;

		void Update ()
		{
			if (m_Fx == EType.Type1)
			{
				m_Resolution = 2f;
				m_EdgeSize = 1f;
				m_EdgePower = 1f;
			}
			else if (m_Fx == EType.Type2)
			{
				m_Resolution = 2f;
				m_EdgeSize = 2f;
				m_EdgePower = 3f;
			}
			else if (m_Fx == EType.Type3)
			{
				m_Resolution = 2f;
				m_EdgeSize = 2f;
				m_EdgePower = 9f;
			}
			m_Mat.SetFloat ("_Resolution", m_Resolution);
			m_Mat.SetFloat ("_EdgeSize", m_EdgeSize);
			m_Mat.SetFloat ("_EdgePower", m_EdgePower);
		}
		void OnRenderImage (RenderTexture src, RenderTexture dst)
		{
			RenderTexture rt1 = RenderTexture.GetTemporary (Screen.width, Screen.height);
			RenderTexture rt2 = RenderTexture.GetTemporary (Screen.width, Screen.height);
			Graphics.Blit (src, rt1, m_Mat, 0);
			RenderTexture rtResult = rt1;
			for (int i = 1; i < m_Pass; i++)
			{
				if (i % 2 == 1)   // the odd num pass
				{
					Graphics.Blit (rt1, rt2, m_Mat, 0);
					rtResult = rt2;
				}
				else   // the even num pass
				{
					Graphics.Blit (rt2, rt1, m_Mat, 0);
					rtResult = rt1;
				}
			}
			Graphics.Blit (rtResult, dst, m_Mat, 1);
			RenderTexture.ReleaseTemporary (rt1);
			RenderTexture.ReleaseTemporary (rt2);
		}
	}
}