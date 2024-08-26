using UnityEngine;

namespace NprPaintFilter
{
	[RequireComponent(typeof(Camera))]
	class MangaSpeedLine : MonoBehaviour
	{
		public Material m_Mat;
		public GameObject m_Target;
		Camera m_Cam;
		float m_Delta;
		int m_ID_CenterX;
		int m_ID_CenterY;
		int m_ID_CentralEdge;
		int m_ID_CentralLength;
		int m_ID_Central;
		static readonly float EDGE_MAX = 0.35f;

		void Start ()
		{
			m_Cam = GetComponent<Camera>();
			m_ID_CenterX = Shader.PropertyToID ("_CenterX");
			m_ID_CenterY = Shader.PropertyToID ("_CenterY");
			m_ID_CentralEdge = Shader.PropertyToID ("_CentralEdge");
			m_ID_CentralLength = Shader.PropertyToID ("_CentralLength");
			m_ID_Central = Shader.PropertyToID ("_Central");
		}
		void Update ()
		{
			var position = m_Target.transform.position;
			var scrpos = m_Cam.WorldToScreenPoint (m_Target.transform.position);
			m_Mat.SetFloat (m_ID_CenterX, scrpos.x / Screen.width);
			m_Mat.SetFloat (m_ID_CenterY, scrpos.y / Screen.height);

			float distance = Vector3.Distance (position, m_Cam.transform.position) / 10f;
			float edge = EDGE_MAX * (1f - Mathf.Clamp (distance / 10f, 0f, EDGE_MAX) / EDGE_MAX);
			m_Mat.SetFloat (m_ID_CentralEdge, edge);
			m_Mat.SetFloat (m_ID_CentralLength, edge + distance / 10f);

			float central = (0.01f*(0.5f*Mathf.Sin(Time.realtimeSinceStartup*32f)+0.5f)+0.2f) + distance / 100f;
			if (m_Delta < 0)
			{
				m_Mat.SetFloat (m_ID_Central, central);
				m_Delta = 0;
			}
			else
			{
				m_Delta -= Time.deltaTime;
				m_Mat.SetFloat (m_ID_Central, Mathf.Lerp(central, 0, m_Delta * 2f));
			}
		}
		void OnRenderImage (RenderTexture src, RenderTexture dst)
		{
			Graphics.Blit (src, dst, m_Mat);
		}
	}
}