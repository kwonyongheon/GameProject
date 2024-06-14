using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Weapon : MonoBehaviour
{
    public enum Type { Range };
    public enum RangeType { Rifle, Shotgun, Sniper }; // �߰��� ���� Ÿ��
    public Type type;
    public RangeType rangeType; // ���� Ÿ��
    public int damage; // ������
    public float rate; // ����(���x)
    public int maxAmmo; // �ִ� ź ����
    public int curAmmo; // ���� ���� �ִ� ź ����

    public Camera playerCamera; // �÷��̾� ī�޶�

    private float lastShotTime; // ���������� �߻��� �ð�
    private float cooldown; // ���⺰ ��Ÿ��

    void Start()
    {
        // ���� Ÿ�Ժ� ��Ÿ�� ����
        if (type == Type.Range)
        {
            switch (rangeType)
            {
                case RangeType.Rifle:
                    cooldown = 0.3f;
                    break;
                case RangeType.Shotgun:
                    cooldown = 1.0f;
                    break;
                case RangeType.Sniper:
                    cooldown = 2.0f;
                    break;
            }
        }

        lastShotTime = -cooldown; // ���� ���� �� �ٷ� �� �� �ֵ��� �ʱ�ȭ
    }

    // �÷��̾ ���� ���
    public void Use()
    {
        if (type == Type.Range && Time.time - lastShotTime >= cooldown && curAmmo > 0) // ��Ÿ���� ������ ź ������ 0���� Ŭ ��
        {
            lastShotTime = Time.time; // ������ �߻� �ð� ����
            curAmmo--;
            StartCoroutine(Shot());
        }
    }

    IEnumerator Shot()
    {
        // �߻� ����
        Ray ray = playerCamera.ViewportPointToRay(new Vector3(0.5f, 0.5f, 0f)); // ȭ�� �߾ӿ��� Ray �߻�
        RaycastHit hit;

        if (Physics.Raycast(ray, out hit))
        {
            Enemy enemy = hit.collider.GetComponent<Enemy>();
            if (enemy != null)
            {
                enemy.TakeDamage(damage);
            }
        }

        yield return null;
    }
}
