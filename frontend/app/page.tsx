"use client";

import { FormEvent, useEffect, useState } from "react";

type Match = {

  match_id?: number;

  complaint_id: number;

  subject: string;

  description: string;

  similarity: number;

  match_status?: string;

};

type ApiResponse = {

  success: boolean;

  complaint_id: number;

  matches: Match[];

};

type Agent = {

  agent_id: number;

  agent_name: string;

  department_name: string;

};

type AgentComplaint = {

  complaint_id: number;

  subject: string;

  description: string;

  created_at: string;

  priority_name: string;

  status_name: string;

  customer_name: string;

  assignment_status: string;

};

function CustomerMatchDecisions({ complaintId }: { complaintId: number }) {
  const [matches, setMatches] = useState<any[]>([]);
  useEffect(() => {
    fetch(`http://127.0.0.1:8000/complaints/${complaintId}/matches`).then(r => r.json()).then(d => setMatches(d.matches || [])).catch(() => setMatches([]));
  }, [complaintId]);
  if (!matches.length) return <p className="mt-2 text-sm text-gray-500">No AI match decisions are available.</p>;
  return <div className="mt-3 space-y-2">{matches.map(m => <div key={m.match_id} className="flex items-center justify-between gap-3 rounded-lg border border-white/10 px-3 py-2"><span className="text-xs text-gray-300">Historical complaint #{m.complaint_id}</span><span className={`text-xs ${m.match_status === "Accepted" ? "text-green-400" : m.match_status === "Rejected" ? "text-red-400" : "text-yellow-300"}`}>{m.match_status}</span></div>)}</div>;
}

export default function Home() {

  const [mode, setMode] = useState<"customer" | "agent">("customer");

  // Customer

  const [subject, setSubject] = useState("");

  const [description, setDescription] = useState("");

  const [productId, setProductId] = useState("1");

  const [categoryId, setCategoryId] = useState("1");

  const [priorityId, setPriorityId] = useState("2");

  const [loading, setLoading] = useState(false);

  const [result, setResult] = useState<ApiResponse | null>(null);

  const [error, setError] = useState("");
  const [customers, setCustomers] = useState<{customer_id:number; customer_name:string}[]>([]);
  const [selectedCustomerId, setSelectedCustomerId] = useState("1");
  const [customerComplaints, setCustomerComplaints] = useState<any[]>([]);
  const [trackedComplaintId, setTrackedComplaintId] = useState<number | null>(null);
  const [customerUpdates, setCustomerUpdates] = useState<any[]>([]);
  const [trackingError, setTrackingError] = useState("");

  // Agent

  const [agents, setAgents] = useState<Agent[]>([]);

  const [selectedAgentId, setSelectedAgentId] = useState("1");

  const [agentComplaints, setAgentComplaints] = useState<AgentComplaint[]>(

    []

  );

  const [selectedComplaint, setSelectedComplaint] =

    useState<AgentComplaint | null>(null);

  const [agentLoading, setAgentLoading] = useState(false);

  const [agentError, setAgentError] = useState("");

  // Matches

  const [agentMatches, setAgentMatches] = useState<Match[]>([]);

  const [matchesLoading, setMatchesLoading] = useState(false);

  const [updatingMatchId, setUpdatingMatchId] = useState<number | null>(null);

  const [matchError, setMatchError] = useState("");
  const [updateType, setUpdateType] = useState("Suggestion");
  const [updateMessage, setUpdateMessage] = useState("");
  const [updateStatus, setUpdateStatus] = useState("In Progress");
  const [postingUpdate, setPostingUpdate] = useState(false);
  const [updateNotice, setUpdateNotice] = useState("");

  const products = [

    { id: 1, name: "Mobile Banking App" },

    { id: 2, name: "Credit Card" },

    { id: 3, name: "Online Payment Gateway" },

    { id: 4, name: "Home Delivery Service" },

  ];

  const categories = [

    { id: 1, name: "Technical Issue" },

    { id: 2, name: "Billing Issue" },

    { id: 3, name: "Product Issue" },

    { id: 4, name: "Delivery Issue" },

    { id: 5, name: "Account Issue" },

  ];

  const priorities = [

    { id: 1, name: "Low" },

    { id: 2, name: "Medium" },

    { id: 3, name: "High" },

    { id: 4, name: "Critical" },

  ];

  // ============================================================

  // Load agents

  // ============================================================

  useEffect(() => {

    async function loadAgents() {

      try {

        const response = await fetch("http://127.0.0.1:8000/agents");

        const data = await response.json();

        if (response.ok) {

          setAgents(data.agents || []);

        }

      } catch {

        console.error("Unable to load agents.");

      }

    }

    loadAgents();

  }, []);

  // CUSTOMER TRACKING DATA LOADERS

  // Load demo customer profiles
  useEffect(() => {
    async function loadCustomers() {
      try {
        const response = await fetch("http://127.0.0.1:8000/customers");
        const data = await response.json();

        if (!response.ok) {
          throw new Error("Unable to load customer profiles.");
        }

        const list = data.customers || [];
        setCustomers(list);

        if (list.length > 0) {
          setSelectedCustomerId((current) =>
            list.some((customer: any) => String(customer.customer_id) === current)
              ? current
              : String(list[0].customer_id)
          );
        }
      } catch (error) {
        setTrackingError(
          error instanceof Error
            ? error.message
            : "Unable to connect to the customer service."
        );
      }
    }

    loadCustomers();
  }, []);

  // Load complaints whenever the selected customer changes
  useEffect(() => {
    async function loadCustomerComplaints() {
      setCustomerComplaints([]);
      setTrackedComplaintId(null);
      setCustomerUpdates([]);
      setTrackingError("");

      if (!selectedCustomerId) return;

      try {
        const response = await fetch(
          `http://127.0.0.1:8000/customers/${selectedCustomerId}/complaints`
        );
        const data = await response.json();

        if (!response.ok) {
          throw new Error("Unable to load this customer's complaints.");
        }

        const complaints = data.complaints || [];
        setCustomerComplaints(complaints);

        if (complaints.length > 0) {
          setTrackedComplaintId(complaints[0].complaint_id);
        }
      } catch (error) {
        setTrackingError(
          error instanceof Error
            ? error.message
            : "Unable to load customer complaints."
        );
      }
    }

    loadCustomerComplaints();
  }, [selectedCustomerId]);

  // Load agent updates whenever a complaint is selected
  useEffect(() => {
    async function loadCustomerUpdates() {
      setCustomerUpdates([]);

      if (trackedComplaintId === null) return;

      try {
        const response = await fetch(
          `http://127.0.0.1:8000/complaints/${trackedComplaintId}/updates`
        );
        const data = await response.json();

        if (!response.ok) {
          throw new Error("Unable to load complaint updates.");
        }

        setCustomerUpdates(data.updates || []);
      } catch (error) {
        setTrackingError(
          error instanceof Error
            ? error.message
            : "Unable to load complaint updates."
        );
      }
    }

    loadCustomerUpdates();
  }, [trackedComplaintId]);

  // ============================================================

  // Customer complaint submission

  // ============================================================

  async function handleSubmit(e: FormEvent<HTMLFormElement>) {

    e.preventDefault();

    setLoading(true);

    setError("");

    setResult(null);

    try {

      const response = await fetch("http://127.0.0.1:8000/complaints", {

        method: "POST",

        headers: {

          "Content-Type": "application/json",

        },

        body: JSON.stringify({

          customer_id: Number(selectedCustomerId),
          subject,

          description,

          product_id: Number(productId),

          category_id: Number(categoryId),

          priority_id: Number(priorityId),

        }),

      });

      const data = await response.json();

      if (!response.ok) {

        throw new Error(

          data.detail || "Something went wrong while submitting the complaint."

        );

      }

      setResult(data);

      setSubject("");

      setDescription("");

    } catch (err) {

      if (err instanceof Error) {

        setError(err.message);

      } else {

        setError("Unable to connect to the ResolveIQ API.");

      }

    } finally {

      setLoading(false);

    }

  }

  // ============================================================

  // Load complaints for selected agent

  // ============================================================

  useEffect(() => {

    if (mode !== "agent") return;

    async function loadAgentComplaints() {

      setAgentLoading(true);

      setAgentError("");

      setSelectedComplaint(null);

      setAgentMatches([]);

      try {

        const response = await fetch(

          `http://127.0.0.1:8000/agents/${selectedAgentId}/complaints`

        );

        const data = await response.json();

        if (!response.ok) {

          throw new Error("Unable to load agent complaints.");

        }

        setAgentComplaints(data.complaints || []);

        if (data.complaints?.length > 0) {

          setSelectedComplaint(data.complaints[0]);

        }

      } catch (err) {

        if (err instanceof Error) {

          setAgentError(err.message);

        } else {

          setAgentError("Unable to connect to the ResolveIQ API.");

        }

        setAgentComplaints([]);

      } finally {

        setAgentLoading(false);

      }

    }

    loadAgentComplaints();

  }, [mode, selectedAgentId]);

  // ============================================================

  // Load matches for selected complaint

  // ============================================================

  useEffect(() => {

    if (!selectedComplaint) {

      setAgentMatches([]);

      return;

    }

    async function loadMatches() {

      setMatchesLoading(true);

      try {

        const response = await fetch(

          `http://127.0.0.1:8000/complaints/${selectedComplaint!.complaint_id}/matches`

        );

        const data = await response.json();

        if (response.ok) {

          setAgentMatches(data.matches || []);

        } else {

          setAgentMatches([]);

        }

      } catch {

        setAgentMatches([]);

      } finally {

        setMatchesLoading(false);

      }

    }

    loadMatches();

  }, [selectedComplaint]);

  async function handleMatchDecision(
    matchId: number,
    status: "Accepted" | "Rejected"
  ) {
    setUpdatingMatchId(matchId);
    setMatchError("");

    try {
      const response = await fetch(
        `http://127.0.0.1:8000/matches/${matchId}/status`,
        {
          method: "PATCH",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify({ match_status: status }),
        }
      );

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.detail || "Unable to update match status.");
      }

      setAgentMatches((previousMatches) =>
        previousMatches.map((match) =>
          match.match_id === matchId
            ? { ...match, match_status: status }
            : match
        )
      );
    } catch (err) {
      setMatchError(
        err instanceof Error
          ? err.message
          : "Unable to connect to the ResolveIQ API."
      );
    } finally {
      setUpdatingMatchId(null);
    }
  }

  async function postAgentUpdate(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    if (!selectedComplaint) return;
    setPostingUpdate(true);
    setUpdateNotice("");
    try {
      const response = await fetch(`http://127.0.0.1:8000/complaints/${selectedComplaint.complaint_id}/updates`, {
        method: "POST", headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ agent_id: Number(selectedAgentId), update_type: updateType, update_message: updateMessage, status_name: updateStatus })
      });
      const data = await response.json();
      if (!response.ok) throw new Error(data.detail || "Unable to post update");
      setUpdateMessage("");
      setUpdateNotice("Update posted successfully and is visible in Customer tracking.");
    } catch (err) { setUpdateNotice(err instanceof Error ? err.message : "Unable to post update"); }
    finally { setPostingUpdate(false); }
  }

  const selectedAgent = agents.find(

    (agent) => String(agent.agent_id) === selectedAgentId

  );

  return (

    <main className="min-h-screen bg-[#08090c] text-white">

      {/* Header */}

      <header className="border-b border-white/10">

        <div className="mx-auto flex max-w-6xl items-center justify-between px-6 py-5">

          <div className="flex items-center gap-3">

            <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-blue-600 font-bold">

              R

            </div>

            <div>

              <h1 className="text-lg font-semibold tracking-tight">

                ResolveIQ

              </h1>

              <p className="text-xs text-gray-500">

                Customer Complaint Resolution

              </p>

            </div>

          </div>

          <div className="flex rounded-xl border border-white/10 bg-white/[0.03] p-1">

            <button

              onClick={() => setMode("customer")}

              className={`rounded-lg px-4 py-2 text-xs font-medium transition ${

                mode === "customer"

                  ? "bg-blue-600 text-white"

                  : "text-gray-500 hover:text-gray-300"

              }`}

            >

              Customer

            </button>

            <button

              onClick={() => setMode("agent")}

              className={`rounded-lg px-4 py-2 text-xs font-medium transition ${

                mode === "agent"

                  ? "bg-blue-600 text-white"

                  : "text-gray-500 hover:text-gray-300"

              }`}

            >

              Support Agent

            </button>

          </div>

        </div>

      </header>

      <div className="mx-auto max-w-6xl px-6 py-14">

        {/* ======================================================

            CUSTOMER VIEW

        ====================================================== */}

        {mode === "customer" && (

          <>

            <section className="mb-6 rounded-2xl border border-white/10 bg-white/[0.03] p-5">
              <label className="mb-2 block text-sm font-medium text-gray-300">Demo customer profile</label>
              <select value={selectedCustomerId} onChange={(e) => setSelectedCustomerId(e.target.value)} className="w-full rounded-xl border border-white/10 bg-[#111318] px-4 py-3 text-sm text-white sm:max-w-md">
                {customers.map((customer) => <option key={customer.customer_id} value={customer.customer_id}>{customer.customer_name}</option>)}
              </select>
              <p className="mt-2 text-xs text-gray-500">Demo profile selector for this project; production access should use authenticated customer accounts.</p>
            </section>

            <section className="mb-12">

              <p className="mb-3 text-sm font-medium text-blue-400">

                SMART COMPLAINT MANAGEMENT

              </p>

              <h2 className="max-w-3xl text-4xl font-bold tracking-tight sm:text-5xl">

                How can we help?

              </h2>

              <p className="mt-4 max-w-2xl text-base leading-7 text-gray-400">

                Submit your complaint and ResolveIQ will find similar

                historical complaints to help support agents resolve your

                issue faster.

              </p>

            </section>

            <section className="mb-12 grid gap-4 md:grid-cols-3">

              <div className="rounded-2xl border border-white/10 bg-white/[0.03] p-6">

                <div className="mb-4 flex h-10 w-10 items-center justify-center rounded-xl bg-blue-500/10 text-sm font-bold text-blue-400">

                  01

                </div>

                <h3 className="font-semibold">Submit</h3>

                <p className="mt-2 text-sm leading-6 text-gray-500">

                  Describe your complaint and provide the relevant product and

                  category.

                </p>

              </div>

              <div className="rounded-2xl border border-white/10 bg-white/[0.03] p-6">

                <div className="mb-4 flex h-10 w-10 items-center justify-center rounded-xl bg-purple-500/10 text-sm font-bold text-purple-400">

                  02

                </div>

                <h3 className="font-semibold">Match</h3>

                <p className="mt-2 text-sm leading-6 text-gray-500">

                  AI embeddings find semantically similar historical

                  complaints.

                </p>

              </div>

              <div className="rounded-2xl border border-white/10 bg-white/[0.03] p-6">

                <div className="mb-4 flex h-10 w-10 items-center justify-center rounded-xl bg-green-500/10 text-sm font-bold text-green-400">

                  03

                </div>

                <h3 className="font-semibold">Resolve</h3>

                <p className="mt-2 text-sm leading-6 text-gray-500">

                  Support agents use previous cases to resolve issues faster.

                </p>

              </div>

            </section>

            <section className="grid gap-8 lg:grid-cols-[1.2fr_0.8fr]">

              <div className="rounded-2xl border border-white/10 bg-white/[0.03] p-7">

                <div className="mb-7">

                  <h3 className="text-xl font-semibold">

                    Submit a complaint

                  </h3>

                  <p className="mt-2 text-sm text-gray-500">

                    Tell us what went wrong and our system will look for

                    similar cases.

                  </p>

                </div>

                <form onSubmit={handleSubmit} className="space-y-5">

                  <div>

                    <label className="mb-2 block text-sm font-medium text-gray-300">

                      Subject

                    </label>

                    <input

                      type="text"

                      value={subject}

                      onChange={(e) => setSubject(e.target.value)}

                      placeholder="Briefly describe your issue"

                      required

                      className="w-full rounded-xl border border-white/10 bg-black/20 px-4 py-3 text-sm text-white outline-none placeholder:text-gray-600 focus:border-blue-500/50"

                    />

                  </div>

                  <div className="grid gap-5 sm:grid-cols-2">

                    <div>

                      <label className="mb-2 block text-sm font-medium text-gray-300">

                        Product

                      </label>

                      <select

                        value={productId}

                        onChange={(e) => setProductId(e.target.value)}

                        className="w-full rounded-xl border border-white/10 bg-[#111318] px-4 py-3 text-sm text-white outline-none focus:border-blue-500/50"

                      >

                        {products.map((product) => (

                          <option key={product.id} value={product.id}>

                            {product.name}

                          </option>

                        ))}

                      </select>

                    </div>

                    <div>

                      <label className="mb-2 block text-sm font-medium text-gray-300">

                        Category

                      </label>

                      <select

                        value={categoryId}

                        onChange={(e) => setCategoryId(e.target.value)}

                        className="w-full rounded-xl border border-white/10 bg-[#111318] px-4 py-3 text-sm text-white outline-none focus:border-blue-500/50"

                      >

                        {categories.map((category) => (

                          <option key={category.id} value={category.id}>

                            {category.name}

                          </option>

                        ))}

                      </select>

                    </div>

                  </div>

                  <div>

                    <label className="mb-2 block text-sm font-medium text-gray-300">

                      Priority

                    </label>

                    <select

                      value={priorityId}

                      onChange={(e) => setPriorityId(e.target.value)}

                      className="w-full rounded-xl border border-white/10 bg-[#111318] px-4 py-3 text-sm text-white outline-none focus:border-blue-500/50"

                    >

                      {priorities.map((priority) => (

                        <option key={priority.id} value={priority.id}>

                          {priority.name}

                        </option>

                      ))}

                    </select>

                  </div>

                  <div>

                    <label className="mb-2 block text-sm font-medium text-gray-300">

                      Description

                    </label>

                    <textarea

                      value={description}

                      onChange={(e) => setDescription(e.target.value)}

                      placeholder="Explain what happened in detail..."

                      required

                      rows={6}

                      className="w-full resize-none rounded-xl border border-white/10 bg-black/20 px-4 py-3 text-sm leading-6 text-white outline-none placeholder:text-gray-600 focus:border-blue-500/50"

                    />

                  </div>

                  {error && (

                    <div className="rounded-xl border border-red-500/20 bg-red-500/10 px-4 py-3 text-sm text-red-400">

                      {error}

                    </div>

                  )}

                  <button

                    type="submit"

                    disabled={loading}

                    className="w-full rounded-xl bg-blue-600 px-5 py-3.5 text-sm font-semibold transition hover:bg-blue-500 disabled:cursor-not-allowed disabled:opacity-50"

                  >

                    {loading ? "Analyzing complaint..." : "Submit Complaint"}

                  </button>

                </form>

              </div>

              <div className="space-y-5">

                <div className="rounded-2xl border border-white/10 bg-white/[0.03] p-7">

                  <h3 className="font-semibold">AI-powered matching</h3>

                  <p className="mt-3 text-sm leading-6 text-gray-500">

                    ResolveIQ uses the{" "}

                    <span className="text-gray-300">

                      all-MiniLM-L6-v2

                    </span>{" "}

                    model to create 384-dimensional embeddings and searches

                    Qdrant using cosine similarity.

                  </p>

                  <div className="mt-5 grid grid-cols-2 gap-3">

                    <div className="rounded-xl border border-white/10 bg-black/20 p-4">

                      <p className="text-xs text-gray-500">Embedding</p>

                      <p className="mt-1 font-semibold">384D</p>

                    </div>

                    <div className="rounded-xl border border-white/10 bg-black/20 p-4">

                      <p className="text-xs text-gray-500">Metric</p>

                      <p className="mt-1 font-semibold">Cosine</p>

                    </div>

                  </div>

                </div>

                {result && (

                  <div className="rounded-2xl border border-green-500/20 bg-green-500/[0.04] p-7">

                    <p className="text-xs font-medium uppercase tracking-wider text-green-400">

                      Complaint submitted

                    </p>

                    <h3 className="mt-1 text-lg font-semibold">

                      Complaint #{result.complaint_id}

                    </h3>

                    <h4 className="mt-6 text-sm font-semibold">

                      Similar complaints

                    </h4>

                    {result.matches.length === 0 ? (

                      <p className="mt-3 text-sm text-gray-500">

                        No sufficiently similar historical complaints were

                        found.

                      </p>

                    ) : (

                      <div className="mt-4 space-y-3">

                        {result.matches.map((match) => (

                          <div

                            key={match.complaint_id}

                            className="rounded-xl border border-white/10 bg-black/20 p-4"

                          >

                            <div className="flex items-start justify-between gap-3">

                              <div>

                                <p className="text-xs text-gray-500">

                                  Complaint #{match.complaint_id}

                                </p>

                                <p className="mt-1 text-sm font-medium">

                                  {match.subject}

                                </p>

                              </div>

                              <span className="shrink-0 rounded-full bg-blue-500/10 px-2.5 py-1 text-xs font-medium text-blue-400">

                                {(match.similarity * 100).toFixed(1)}% match

                              </span>

                            </div>

                            <p className="mt-3 text-xs leading-5 text-gray-500">

                              {match.description}

                            </p>

                          </div>

                        ))}

                      </div>

                    )}

                  </div>

                )}

              </div>

            </section>

            <section className="mt-10 rounded-2xl border border-white/10 bg-white/[0.03] p-7">
              <div className="flex flex-wrap items-center justify-between gap-3">
                <div><p className="text-xs font-medium uppercase tracking-wider text-blue-400">Customer portal</p><h3 className="mt-1 text-xl font-semibold">My Complaints</h3><p className="mt-2 text-sm text-gray-500">Track the assigned agent, complaint status, AI decisions and agent recommendations.</p></div>
                <span className="rounded-full bg-blue-500/10 px-3 py-1 text-xs text-blue-300">{customerComplaints.length} complaints</span>
              </div>
              {trackingError && <p className="mt-4 text-sm text-red-400">{trackingError}</p>}
              <div className="mt-6 grid gap-5 lg:grid-cols-[0.85fr_1.15fr]">
                <div className="space-y-3">
                  {customerComplaints.length === 0 ? <p className="text-sm text-gray-500">No complaints found for this customer profile.</p> : customerComplaints.map((c:any) => <button key={c.complaint_id} onClick={() => setTrackedComplaintId(c.complaint_id)} className={`w-full rounded-xl border p-4 text-left ${trackedComplaintId === c.complaint_id ? "border-blue-500/50 bg-blue-500/10" : "border-white/10 bg-black/20"}`}><div className="flex justify-between gap-3"><span className="text-xs text-gray-500">Complaint #{c.complaint_id}</span><span className="text-xs text-blue-300">{c.status_name}</span></div><p className="mt-2 text-sm font-medium">{c.subject}</p><p className="mt-2 text-xs text-gray-500">{c.agent_name ? `Agent: ${c.agent_name} · ${c.department_name}` : "Awaiting agent assignment"}</p></button>)}
                </div>
                <div className="rounded-xl border border-white/10 bg-black/20 p-5">
                  {!trackedComplaintId ? <p className="text-sm text-gray-500">Select a complaint to view its tracking details.</p> : (() => { const c = customerComplaints.find((item:any) => item.complaint_id === trackedComplaintId); return c ? <><div className="flex flex-wrap justify-between gap-3"><div><p className="text-xs text-gray-500">Complaint #{c.complaint_id}</p><h4 className="mt-1 text-lg font-semibold">{c.subject}</h4></div><span className="h-fit rounded-full bg-blue-500/10 px-3 py-1 text-xs text-blue-300">{c.status_name}</span></div><div className="mt-5 rounded-lg border border-white/10 p-4"><p className="text-xs text-gray-500">Assigned support agent</p><p className="mt-1 font-medium">{c.agent_name || "Not assigned yet"}</p><p className="text-xs text-gray-500">{c.department_name || "Assignment pending"}</p></div><div className="mt-5"><h5 className="font-semibold">AI match decisions</h5><p className="mt-1 text-xs text-gray-500">Accepted and rejected historical cases are shown in the agent workspace; the customer can see the decision status.</p></div><CustomerMatchDecisions complaintId={c.complaint_id} /><div className="mt-6"><h5 className="font-semibold">Agent updates and suggestions</h5>{customerUpdates.length === 0 ? <p className="mt-2 text-sm text-gray-500">No agent updates have been posted yet.</p> : <div className="mt-3 space-y-3">{customerUpdates.map((u:any) => <div key={u.update_id} className="rounded-lg border border-white/10 p-4"><div className="flex flex-wrap justify-between gap-2"><span className="text-xs font-medium text-purple-300">{u.update_type}</span><span className="text-xs text-gray-500">{new Date(u.created_at).toLocaleString()}</span></div><p className="mt-2 text-sm leading-6 text-gray-200">{u.update_message}</p><p className="mt-2 text-xs text-gray-500">{u.agent_name} · {u.department_name}</p></div>)}</div>}</div></> : <p className="text-sm text-gray-500">Complaint not found.</p>; })()}
                </div>
              </div>
            </section>

          </>

        )}

        {/* ======================================================

            AGENT VIEW

        ====================================================== */}

        {mode === "agent" && (

          <>

            <section className="mb-10">

              <p className="mb-3 text-sm font-medium text-blue-400">

                SUPPORT AGENT WORKSPACE

              </p>

              <h2 className="text-4xl font-bold tracking-tight">

                Agent Dashboard

              </h2>

              <p className="mt-3 text-gray-500">

                Review assigned complaints and use AI-powered historical

                matches to resolve customer issues.

              </p>

            </section>

            {/* Agent selector */}

            <div className="mb-6 rounded-2xl border border-white/10 bg-white/[0.03] p-5">

              <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">

                <div>

                  <p className="text-sm font-semibold">Support Agent</p>

                  <p className="mt-1 text-xs text-gray-500">

                    Select an agent to view their active assignments.

                  </p>

                </div>

                <select

                  value={selectedAgentId}

                  onChange={(e) => setSelectedAgentId(e.target.value)}

                  className="rounded-xl border border-white/10 bg-[#111318] px-4 py-3 text-sm text-white outline-none focus:border-blue-500/50 sm:min-w-[280px]"

                >

                  {agents.map((agent) => (

                    <option key={agent.agent_id} value={agent.agent_id}>

                      {agent.agent_name} · {agent.department_name}

                    </option>

                  ))}

                </select>

              </div>

            </div>

            {agentError && (

              <div className="mb-6 rounded-xl border border-red-500/20 bg-red-500/10 px-4 py-3 text-sm text-red-400">

                {agentError}

              </div>

            )}

            {agentLoading ? (

              <div className="rounded-2xl border border-white/10 bg-white/[0.03] p-10 text-center text-sm text-gray-500">

                Loading assigned complaints...

              </div>

            ) : agentComplaints.length === 0 ? (

              <div className="rounded-2xl border border-white/10 bg-white/[0.03] p-10 text-center">

                <p className="font-medium">No active complaints assigned</p>

                <p className="mt-2 text-sm text-gray-500">

                  {selectedAgent?.agent_name || "This agent"} currently has no

                  active assignments.

                </p>

              </div>

            ) : (

              <div className="grid gap-6 lg:grid-cols-[0.8fr_1.2fr]">

                {/* Complaint list */}

                <div className="rounded-2xl border border-white/10 bg-white/[0.03] p-5">

                  <div className="mb-5 flex items-center justify-between">

                    <div>

                      <h3 className="font-semibold">

                        Assigned complaints

                      </h3>

                      <p className="mt-1 text-xs text-gray-500">

                        {selectedAgent?.agent_name} · Agent #

                        {selectedAgentId}

                      </p>

                    </div>

                    <span className="rounded-full bg-blue-500/10 px-3 py-1 text-xs text-blue-400">

                      {agentComplaints.length} active

                    </span>

                  </div>

                  <div className="space-y-3">

                    {agentComplaints.map((complaint) => (

                      <button

                        key={complaint.complaint_id}

                        onClick={() => setSelectedComplaint(complaint)}

                        className={`w-full rounded-xl border p-4 text-left transition ${

                          selectedComplaint?.complaint_id ===

                          complaint.complaint_id

                            ? "border-blue-500/40 bg-blue-500/[0.08]"

                            : "border-white/10 bg-black/10 hover:border-white/20"

                        }`}

                      >

                        <div className="flex items-start justify-between gap-3">

                          <div>

                            <p className="text-xs text-gray-500">

                              Complaint #{complaint.complaint_id}

                            </p>

                            <p className="mt-1 text-sm font-medium">

                              {complaint.subject}

                            </p>

                          </div>

                          <span className="rounded-full bg-yellow-500/10 px-2 py-1 text-[11px] text-yellow-400">

                            {complaint.priority_name}

                          </span>

                        </div>

                        <p className="mt-3 text-xs text-gray-500">

                          {complaint.customer_name}

                        </p>

                      </button>

                    ))}

                  </div>

                </div>

                {/* Selected complaint */}

                {selectedComplaint && (

                  <div className="space-y-5">

                    <div className="rounded-2xl border border-white/10 bg-white/[0.03] p-7">

                      <div className="flex items-start justify-between gap-5">

                        <div>

                          <p className="text-xs text-gray-500">

                            Complaint #{selectedComplaint.complaint_id}

                          </p>

                          <h3 className="mt-2 text-2xl font-semibold">

                            {selectedComplaint.subject}

                          </h3>

                        </div>

                        <span className="rounded-full bg-yellow-500/10 px-3 py-1.5 text-xs font-medium text-yellow-400">

                          {selectedComplaint.priority_name}

                        </span>

                      </div>

                      <div className="mt-6 grid gap-4 sm:grid-cols-3">

                        <div>

                          <p className="text-xs text-gray-500">Customer</p>

                          <p className="mt-1 text-sm">

                            {selectedComplaint.customer_name}

                          </p>

                        </div>

                        <div>

                          <p className="text-xs text-gray-500">Status</p>

                          <p className="mt-1 text-sm">

                            {selectedComplaint.status_name}

                          </p>

                        </div>

                        <div>

                          <p className="text-xs text-gray-500">

                            Assignment

                          </p>

                          <p className="mt-1 text-sm">

                            {selectedComplaint.assignment_status}

                          </p>

                        </div>

                      </div>

                      <div className="mt-7">

                        <p className="text-xs font-medium uppercase tracking-wider text-gray-500">

                          Complaint description

                        </p>

                        <p className="mt-3 text-sm leading-7 text-gray-300">

                          {selectedComplaint.description}

                        </p>

                      </div>

                    </div>

                    {/* AI matches */}

                    <div className="rounded-2xl border border-purple-500/20 bg-purple-500/[0.03] p-7">

                      <p className="text-xs font-medium uppercase tracking-wider text-purple-400">

                        ResolveIQ AI

                      </p>

                      <h3 className="mt-1 text-xl font-semibold">

                        Similar historical complaints

                      </h3>

                      <p className="mt-2 text-sm text-gray-500">

                        Use previous cases as reference when resolving this

                        complaint.

                      </p>

                      {matchError && (
                        <div className="mt-5 rounded-xl border border-red-500/20 bg-red-500/10 px-4 py-3 text-sm text-red-400">
                          {matchError}
                        </div>
                      )}

                      {matchesLoading ? (

                        <p className="mt-6 text-sm text-gray-500">

                          Finding similar complaints...

                        </p>

                      ) : agentMatches.length === 0 ? (

                        <p className="mt-6 text-sm text-gray-500">

                          No stored AI matches found for this complaint.

                        </p>

                      ) : (

                        <div className="mt-6 space-y-3">

                          {agentMatches.map((match) => (

                            <div

                              key={match.match_id ?? match.complaint_id}

                              className="rounded-xl border border-white/10 bg-black/20 p-5"

                            >

                              <div className="flex items-start justify-between gap-4">

                                <div>

                                  <p className="text-xs text-gray-500">

                                    Historical complaint #

                                    {match.complaint_id}

                                  </p>

                                  <p className="mt-1 font-medium">

                                    {match.subject}

                                  </p>

                                </div>

                                <span className="rounded-full bg-blue-500/10 px-3 py-1 text-xs font-medium text-blue-400">

                                  {(match.similarity * 100).toFixed(1)}%

                                </span>

                              </div>

                              <p className="mt-3 text-sm leading-6 text-gray-500">

                                {match.description}

                              </p>

                              <div className="mt-4 flex flex-wrap items-center gap-2">
                                <span
                                  className={`rounded-full px-2.5 py-1 text-[11px] font-medium ${
                                    match.match_status === "Accepted"
                                      ? "bg-green-500/10 text-green-400"
                                      : match.match_status === "Rejected"
                                      ? "bg-red-500/10 text-red-400"
                                      : "bg-yellow-500/10 text-yellow-400"
                                  }`}
                                >
                                  {match.match_status || "Suggested"}
                                </span>

                                {match.match_status === "Suggested" && (
                                  <>
                                    <button
                                      type="button"
                                      onClick={() =>
                                        match.match_id !== undefined &&
                                        handleMatchDecision(match.match_id, "Accepted")
                                      }
                                      disabled={
                                        match.match_id === undefined ||
                                        updatingMatchId !== null
                                      }
                                      className="rounded-lg bg-green-600/20 px-3 py-1.5 text-xs font-medium text-green-400 transition hover:bg-green-600/30 disabled:cursor-not-allowed disabled:opacity-40"
                                    >
                                      {updatingMatchId === match.match_id
                                        ? "Updating..."
                                        : "Accept"}
                                    </button>

                                    <button
                                      type="button"
                                      onClick={() =>
                                        match.match_id !== undefined &&
                                        handleMatchDecision(match.match_id, "Rejected")
                                      }
                                      disabled={
                                        match.match_id === undefined ||
                                        updatingMatchId !== null
                                      }
                                      className="rounded-lg bg-red-600/20 px-3 py-1.5 text-xs font-medium text-red-400 transition hover:bg-red-600/30 disabled:cursor-not-allowed disabled:opacity-40"
                                    >
                                      Reject
                                    </button>
                                  </>
                                )}
                              </div>

                            </div>

                          ))}

                        </div>

                      )}

                    </div>

                    <form onSubmit={postAgentUpdate} className="rounded-2xl border border-green-500/20 bg-green-500/[0.03] p-6 space-y-4">
                      <div><p className="text-xs font-medium uppercase tracking-wider text-green-400">Customer communication</p><h3 className="mt-1 text-lg font-semibold">Post an update or suggestion</h3><p className="mt-1 text-sm text-gray-500">Your message will appear in the customer's My Complaints tracking panel.</p></div>
                      <div className="grid gap-3 sm:grid-cols-2"><select value={updateType} onChange={e=>setUpdateType(e.target.value)} className="rounded-xl border border-white/10 bg-[#111318] px-3 py-3 text-sm"><option>Suggestion</option><option>Progress Update</option><option>Resolution</option></select><select value={updateStatus} onChange={e=>setUpdateStatus(e.target.value)} className="rounded-xl border border-white/10 bg-[#111318] px-3 py-3 text-sm"><option>Open</option><option>In Progress</option><option>Resolved</option><option>Closed</option></select></div>
                      <textarea value={updateMessage} onChange={e=>setUpdateMessage(e.target.value)} required maxLength={2000} rows={4} placeholder="Write a clear update or troubleshooting suggestion for the customer..." className="w-full rounded-xl border border-white/10 bg-black/20 px-4 py-3 text-sm text-white" />
                      {updateNotice && <p className="text-sm text-green-300">{updateNotice}</p>}
                      <button disabled={postingUpdate || !updateMessage.trim()} className="rounded-xl bg-green-600 px-5 py-3 text-sm font-semibold disabled:opacity-50">{postingUpdate ? "Posting..." : "Post customer update"}</button>
                    </form>

                  </div>

                )}

              </div>

            )}

          </>

        )}

        <footer className="mt-16 border-t border-white/10 pt-6 text-center text-xs text-gray-600">

          ResolveIQ · Customer Complaint Matching & Resolution System

        </footer>

      </div>

    </main>

  );

}
