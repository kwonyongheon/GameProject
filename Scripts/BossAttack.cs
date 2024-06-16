using System.Collections;
using UnityEngine;

public class BossAttack : MonoBehaviour
{
    public enum ProjectileType { Fireball, Iceball, Slowball } // �߻�ü ����
    public ProjectileType projectileType; // �߻�ü ���� ����

    public int fireballInitialDamage = 20;
    public int fireballTickDamage = 5;
    public float fireballDuration = 3f;

    public int iceballDamage = 15;
    public float iceballFreezeDuration = 0.5f;

    public int slowballDamage = 20;
    public float slowballSlowDuration = 1f; // ���ο� ���� �ð�
    public float slowballSlowMultiplier = 0.7f; // ���ο� �ӵ� ���� ����

    private void OnTriggerEnter(Collider other)
    {
        Debug.Log("�浹 ����: " + other.name);
        if (other.CompareTag("Player"))
        {
            Debug.Log("�߻�ü�� �÷��̾ ������ϴ�.");
            Player player = other.GetComponent<Player>();
            if (player != null)
            {
                switch (projectileType)
                {
                    case ProjectileType.Fireball:
                        player.TakeDamage(fireballInitialDamage);
                        StartCoroutine(ApplyTickDamage(player, fireballTickDamage, fireballDuration));
                        break;
                    case ProjectileType.Iceball:
                        player.TakeDamage(iceballDamage);
                        StartCoroutine(FreezePlayer(player, iceballFreezeDuration));
                        break;
                    case ProjectileType.Slowball:
                        player.TakeDamage(slowballDamage);
                        StartCoroutine(SlowPlayer(player, slowballSlowMultiplier, slowballSlowDuration));
                        break;
                }
                StartCoroutine(DestroyAfterDelay(3f)); // 3�� �Ŀ� �߻�ü �ı�
            }
        }
    }

    private IEnumerator ApplyTickDamage(Player player, int tickDamage, float duration)
    {
        Debug.Log("�÷��̾�� ƽ ������ ���� ��.");
        float tickInterval = 1f;
        float elapsedTime = 0f;
        while (elapsedTime < duration)
        {
            yield return new WaitForSeconds(tickInterval);
            player.TakeDamage(tickDamage);
            elapsedTime += tickInterval;
            Debug.Log("ƽ ������ �����. ��� �ð�: " + elapsedTime);
        }
        Debug.Log("ƽ ������ ���� �Ϸ�.");
    }

    private IEnumerator FreezePlayer(Player player, float duration)
    {
        Debug.Log("�÷��̾� �󸮱�.");
        player.canMove = false;
        yield return new WaitForSeconds(duration);
        player.canMove = true;
        Debug.Log("�÷��̾� ��������.");
    }

    private IEnumerator SlowPlayer(Player player, float slowMultiplier, float duration)
    {
        Debug.Log("�÷��̾� ���ο�.");
        float originalSpeed = player.moveSpeed;
        player.moveSpeed *= slowMultiplier;
        Debug.Log($"�÷��̾� �ӵ� ����: {player.moveSpeed}");
        yield return new WaitForSeconds(duration);
        player.moveSpeed = originalSpeed;
        Debug.Log($"�÷��̾� �ӵ� ����: {player.moveSpeed}");
    }

    private IEnumerator DestroyAfterDelay(float delay)
    {
        yield return new WaitForSeconds(delay);
        Destroy(gameObject);
    }
}
