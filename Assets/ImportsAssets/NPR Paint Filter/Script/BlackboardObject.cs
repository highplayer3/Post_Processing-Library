using UnityEngine;

namespace NprPaintFilter
{
	public class BlackboardObject : MonoBehaviour
	{
		BlackboardCamera m_Bc;
		Material m_Mat;

		void Start ()
		{
			m_Bc = GameObject.FindObjectOfType<BlackboardCamera> ();
			Renderer rd = GetComponent<Renderer> ();
			m_Mat = rd.material;
		}
		void Update ()
		{
			m_Mat.SetTexture ("_MainTex", m_Bc.GetResult ());
		}
	}
}
